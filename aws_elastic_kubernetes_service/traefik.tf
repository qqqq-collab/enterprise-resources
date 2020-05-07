resource "kubernetes_service_account" "traefik_ingress_controller" {
  metadata {
    name      = "traefik"
    namespace = "default"
    annotations = var.resource_tags
  }
}

resource "kubernetes_cluster_role_binding" "traefik_ingress_controller" {
  metadata {
    name = "traefik"
    annotations = var.resource_tags
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.traefik_ingress_controller.metadata[0].name
    namespace = kubernetes_service_account.traefik_ingress_controller.metadata[0].namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"

    # giving cluster-admin is too much access for traefik.
    name = "cluster-admin"
  }
}

data "template_file" "traefik-toml-http" {
  count    = 1 - var.enable_https
  template = <<EOF
defaultEntryPoints = ["http"]
[entryPoints]
  [entryPoints.http]
  address = ":80"
[http.routers]
  [http.routers.codecov]
    middlewares = ["codecov"]
[http.middlewares]
  [http.middlewares.codecov.headers]
    STSSeconds = 0
    ForceSTSHeader = false
EOF

}

data "template_file" "traefik-toml-https" {
  count    = var.enable_https
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
[http.routers]
  [http.routers.codecov]
    middlewares = ["codecov"]
[http.middlewares]
  [http.middlewares.codecov.headers]
    STSSeconds = 0
    ForceSTSHeader = false
EOF
}

resource "kubernetes_config_map" "traefik-toml" {
  metadata {
    name = "traefik-config"
    annotations = var.resource_tags
  }
  data = {
    "traefik.toml" = element(
      concat(
        data.template_file.traefik-toml-http.*.rendered,
        data.template_file.traefik-toml-https.*.rendered,
      ),
      0,
    )
  }
}

resource "kubernetes_secret" "traefik-tls" {
  metadata {
    name = "traefik-tls"
    annotations = var.resource_tags
  }
  type = "tls"
  data = {
    "tls.key" = file(var.tls_key)
    "tls.crt" = file(var.tls_cert)
  }
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name = "traefik"
    annotations = var.resource_tags
  }
  spec {
    replicas = var.traefik_resources["replicas"]
    selector {
      match_labels = {
        app = "traefik"
      }
    }
    template {
      metadata {
        labels = {
          app = "traefik"
        }
      }
      spec {
        node_selector = {
          # run in the web node pool
          "kubernetes.io/role" = "web"
        }
        service_account_name = kubernetes_service_account.traefik_ingress_controller.metadata[0].name
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
          name = kubernetes_service_account.traefik_ingress_controller.default_secret_name
          secret {
            secret_name = kubernetes_service_account.traefik_ingress_controller.default_secret_name
          }
        }
        container {
          name  = "traefik"
          image = "traefik:v1.7-alpine"
          args = [
            "--configfile=/config/traefik.toml",
            "--api",
            "--kubernetes",
          ]
          port {
            name           = "http"
            container_port = "80"
          }
          port {
            name           = "https"
            container_port = "443"
          }
          env {
            name  = "KUBERNETES_SERVICE_HOST"
            value = "kubernetes"
          }
          env {
            name  = "KUBERNETES_SERVICE_PORT"
            value = "443"
          }
          resources {
            limits {
              cpu    = var.traefik_resources["cpu_limit"]
              memory = var.traefik_resources["memory_limit"]
            }
            requests {
              cpu    = var.traefik_resources["cpu_request"]
              memory = var.traefik_resources["memory_request"]
            }
          }
          volume_mount {
            name       = "config"
            read_only  = "true"
            mount_path = "/config"
          }
          volume_mount {
            name       = "cert"
            read_only  = "true"
            mount_path = "/cert"
          }

          # when using terraform, you must explicitly mount the service account secret volume
          # https://github.com/kubernetes/kubernetes/issues/27973
          # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38
          volume_mount {
            name       = kubernetes_service_account.traefik_ingress_controller.default_secret_name
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
    annotations = var.resource_tags
  }
  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = "80"
      target_port = "80"
    }
    port {
      name        = "https"
      protocol    = "TCP"
      port        = "443"
      target_port = "443"
    }
    selector = {
      app = "traefik"
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress" "traefik" {
  metadata {
    name = "traefik"
    annotations = merge({
        "kubernetes.io/ingress.class" = "traefik"
      },
      var.resource_tags
    )
  }
  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path = "/"
          backend {
            service_name = "web"
            service_port = "5000"
          }
        }
      }
    }
  }
}

output "ingress-lb-hostname" {
  value = kubernetes_service.traefik.load_balancer_ingress[0].hostname
}

