resource "kubernetes_deployment" "web" {
  metadata {
    name = "web"
  }
  spec {
    replicas = var.web_replicas
    selector {
      match_labels = {
        app = "web"
      }
    }
    template {
      metadata {
        labels = {
          app = "web"
        }
      }
      spec {
        volume {
          name = "codecov-yml"
          secret {
            secret_name = kubernetes_secret.codecov-yml.metadata[0].name
          }
        }
        container {
          name  = "web"
          image = "codecov/enterprise:v${var.codecov_version}"
          args  = ["web"]
          port {
            container_port = 5000
          }
          env {
            name = "STATSD_HOST"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }
          resources {
            limits {
              cpu    = "256m"
              memory = "512M"
            }
            requests {
              cpu    = "32m"
              memory = "64M"
            }
          }
          readiness_probe {
            http_get {
              path = "/login"
              port = "5000"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          image_pull_policy = "Always"
          volume_mount {
            name       = "codecov-yml"
            read_only  = "true"
            mount_path = "/config"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name = "web"
  }
  spec {
    port {
      protocol    = "TCP"
      port        = "5000"
      target_port = "5000"
    }
    selector = {
      app = "web"
    }
    type = "NodePort"
  }
}

