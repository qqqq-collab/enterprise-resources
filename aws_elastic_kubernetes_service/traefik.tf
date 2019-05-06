# TODO replace hard-coded references between resources with interpolated references
# to the appropriate terraform resource properties to ensure proper dependency 
# resolution.

resource "kubernetes_service_account" "traefik_ingress_controller" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role_binding" "traefik_ingress_controller" {
  metadata {
    name = "traefik-ingress-controller"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.traefik_ingress_controller.metadata.0.name}"
    namespace = "${kubernetes_service_account.traefik_ingress_controller.metadata.0.namespace}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    # giving cluster-admin is too much access for traefik.
    name      = "cluster-admin"
  }
}

data "template_file" "traefik-toml-http" {
  count = "${1 - var.enable_https}"
  template = <<EOF
defaultEntryPoints = ["http"]
[entryPoints]
  [entryPoints.http]
  address = ":80"
EOF
}

data "template_file" "traefik-toml-https" {
  count = "${var.enable_https}"
  template = <<EOF
defaultEntryPoints = ["http","https"]
[entryPoints]
  [entryPoints.http]
  address = ":80"
    [entryPoints.http.redirect]
      entryPoint = "https"
  [entryPoints.https]
  address = ":443"
    [entryPoints.https.tls]
      [[entryPoints.https.tls.certificates]]
      CertFile = "/cert/tls.crt"
      KeyFile = "/cert/tls.key"
EOF
}

resource "kubernetes_config_map" "traefik-toml" {
  metadata {
    name = "traefik-config"
  }
  data {
    "traefik.toml" = "${element(concat(data.template_file.traefik-toml-http.*.rendered,data.template_file.traefik-toml-https.*.rendered),0)}"
  }
}

resource "kubernetes_secret" "traefik-tls" {
  metadata {
    name = "traefik-tls"
  }
  type = "tls"
  data {
    tls.key = "${file("${var.tls_key}")}"
    tls.crt = "${file("${var.tls_cert}")}"
  }
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name = "traefik-ingress-controller"
  }
  spec {
    replicas = "${var.traefik_replicas}"
    selector {
      match_labels {
        app = "traefik-ingress-controller" 
      }
    }
    template {
      metadata {
        labels {
          app = "traefik-ingress-controller"
        }
      }
      spec {
        node_selector {
          # run in the web node pool
          "kubernetes.io/role" = "web"
        }
        service_account_name = "${kubernetes_service_account.traefik_ingress_controller.metadata.0.name}"
        volume {
          name = "config"
          config_map {
            name = "traefik-config"
          }
        }
        volume {
          name = "cert"
          secret {
            secret_name = "traefik-tls"
          }
        }
        volume {
          name = "${kubernetes_service_account.traefik_ingress_controller.default_secret_name}"
          secret {
            secret_name = "${kubernetes_service_account.traefik_ingress_controller.default_secret_name}"
          }
        }
        container {
          name  = "traefik"
          image = "traefik:v1.7-alpine"
          args  = [
            "--configfile=/config/traefik.toml",
            "--api",
            "--kubernetes",
            "--logLevel=INFO"
          ]
          port {
            name = "http"
            container_port = "80"
          }
          port {
            name = "https"
            container_port = "443"
          }
          port {
            name = "admin"
            container_port = "8080"
          }
          env {
            name = "KUBERNETES_SERVICE_HOST"
            value = "kubernetes"
          }
          env {
            name = "KUBERNETES_SERVICE_PORT"
            value = "443"
          }
          volume_mount {
            name = "config"
            read_only = "true"
            mount_path = "/config"
          }
          volume_mount {
            name = "cert"
            read_only = "true"
            mount_path = "/cert"
          }
          # when using terraform, you must explicitly mount the service account secret volume
          # https://github.com/kubernetes/kubernetes/issues/27973
          # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38
          volume_mount {
            name       = "${kubernetes_service_account.traefik_ingress_controller.default_secret_name}"
            read_only  = "true"
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }
        }
      }
    }
    strategy {
      type = "RollingUpdate"
    }
  }
}

resource "kubernetes_service" "traefik" {
  metadata {
    name = "traefik"
  }
  spec {
    port {
      name = "http"
      protocol    = "TCP"
      port        = "80"
      target_port = "80"
    }
    port {
      name = "https"
      protocol    = "TCP"
      port        = "443"
      target_port = "443"
    }
    port {
      name = "admin"
      protocol    = "TCP"
      port        = "8080"
      target_port = "8080"
    }
    selector {
      app = "traefik-ingress-controller"
    }
    type = "LoadBalancer"
  }
}

data "template_file" "traefik-ingress" {
  template = <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-ingress
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: ${var.ingress_host}
    http:
      paths:
      - path: /
        backend:
          serviceName: web
          servicePort: 5000
      - path: /${aws_s3_bucket.minio.id}
        backend:
          serviceName: minio
          servicePort: 9000
      - path: /minio
        backend:
          serviceName: minio
          servicePort: 9000
EOF
}

# work around kubernetes provider's lack of a kubernetes_ingress resource
resource "null_resource" "traefik-ingress" {
  provisioner "local-exec" "traefik-ingress" {
    command = "cat <<EOF | kubectl create -f - \n${data.template_file.traefik-ingress.rendered}\nEOF"
  }

  provisioner "local-exec" "traefik-ingress" {
    when = "destroy"
    command = "kubectl delete ingress traefik-ingress"
  }

  depends_on = ["kubernetes_service.traefik"]
}

locals {
  lb_name_split = "${split("-",kubernetes_service.traefik.load_balancer_ingress.0.hostname)}"
}

# The workaround above creates a dangling ELB for ingress. Since terraform
# is not aware of it it's not removed on destroy and will prevent a full
# destroy from executing properly.  This uses the aws cli to delete the ELB
# first.
resource "null_resource" "ingress-elb" {
  provisioner "local-exec" "traefik-ingress" {
    when = "destroy"
    command = "aws elb delete-load-balancer --load-balancer-name ${local.lb_name_split[0]}"
  }

  depends_on = ["null_resource.traefik-ingress"]
}


output "ingress-lb-hostname" {
  value = "${kubernetes_service.traefik.load_balancer_ingress.0.hostname}"
}
