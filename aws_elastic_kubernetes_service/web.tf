resource "kubernetes_secret" "codecov-yml" {
  metadata {
    name = "codecov-yml"
  }
  data {
    "codecov.yml" = "${file("${var.codecov_yml}")}"
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name = "web"
  }
  spec {
    replicas = "${var.web_replicas}"
    selector {
      match_labels {
        app = "web"
      }
    }
    template {
      metadata {
        labels {
          app = "web"
        }
      }
      spec {
        node_selector {
          "kubernetes.io/role" = "web"
        }
        volume {
          name = "codecov-yml"
          secret {
            secret_name = "${kubernetes_secret.codecov-yml.metadata.0.name}"
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
          env {
            name = "MINIO_PORT_9000_TCP_ADDR"
            value = "minio"
          }
          env {
            name = "MINIO_PORT_9000_TCP_PORT"
            value = "9000"
          }
          env {
            name = "SERVICES__DATABASE_URL"
            value = "${local.postgres_url}"
          }
          env {
            name = "SERVICES__REDIS_URL"
            value = "${local.redis_url}"
          }
          env {
            name = "SERVICES__MINIO__ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = "${kubernetes_secret.minio-access-key.metadata.0.name}"
                key  = "MINIO_ACCESS_KEY"
              }
            }
          }
          env {
            name = "SERVICES__MINIO__SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = "${kubernetes_secret.minio-secret-key.metadata.0.name}"
                key  = "MINIO_SECRET_KEY"
              }
            }
          }
          env {
            name = "SERVICES__MINIO__BUCKET"
            value = "${aws_s3_bucket.minio.id}"
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
            name = "codecov-yml"
            read_only = "true"
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
    selector {
      app = "web"
    }
  }
}
