# TODO replace hard-coded references between resources with interpolated references
# to the appropirate terraform resource properties

resource "kubernetes_cluster_role" "traefik_ingress_controller" {
  metadata {
    name = "traefik-ingress-controller"
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }
}

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
    name      = "traefik-ingress-controller"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "traefik-ingress-controller"
  }
}

resource "kubernetes_config_map" "traefik-toml" {
  metadata {
    name = "traefik-config"
  }
  data {
    "traefik.toml" = "${file("${path.module}/traefik.toml")}"
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
        service_account_name = "traefik-ingress-controller"
        volume {
          name = "config"
          config_map {
            name = "traefik-config"
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
            "--logLevel=DEBUG"
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
            value = "10.96.0.1"
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
    type = "NodePort"
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
      - path: /archive
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
