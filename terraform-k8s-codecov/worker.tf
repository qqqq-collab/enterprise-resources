resource "kubernetes_deployment" "worker" {
  metadata {
    name = "worker"
  }
  spec {
    replicas = "${var.worker_replicas}"
    selector {
      match_labels {
        app = "worker"
      }
    }
    template {
      metadata {
        labels {
          app = "worker"
        }
      }
      spec {
        volume {
          name = "codecov-yml"
          secret {
            secret_name = "${kubernetes_secret.codecov-yml.metadata.0.name}"
          }
        }
        container {
          name  = "workers"
          image = "codecov/enterprise:v4.4.4"
          args  = ["worker", "--queue celery,uploads", "--concurrency 1"]
          env {
            name  = "REDIS_URL"
            value = "redis://${var.redis_host}"
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
          resources {
            limits {
              cpu    = "512m"
              memory = "2048M"
            }
            requests {
              cpu    = "256m"
              memory = "2048M"
            }
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
    strategy {
      type = "RollingUpdate"
    }
  }
}
