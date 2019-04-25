
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
#        node_selector {
#          role = "${google_container_node_pool.worker.node_config.0.labels.role}"
#        }
        volume {
          name = "codecov-yml"
          secret {
            secret_name = "${kubernetes_secret.codecov-yml.metadata.0.name}"
          }
        }
        container {
          name  = "workers"
          image = "codecov/enterprise:v${var.codecov_version}"
          args  = ["worker", "--queue celery,uploads", "--concurrency 1"]
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
