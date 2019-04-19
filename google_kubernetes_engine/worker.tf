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
            value = "postgres://${google_sql_user.codecov.name}:${google_sql_user.codecov.password}@127.0.0.1:5432/${google_sql_database.codecov.name}"
          }
          env {
            name = "SERVICES__REDIS_URL"
            value = "redis://${google_redis_instance.codecov.host}:${google_redis_instance.codecov.port}"
          }
          env {
            name = "SERVICES__MINIO__ACCESS_KEY_ID"
            value = "${var.minio_access_key}"
          }
          env {
            name = "SERVICES__MINIO__SECRET_ACCESS_KEY"
            value = "${var.minio_secret_key}"
          }
          env {
            name = "SERVICES__MINIO__BUCKET"
            value = "${var.minio_bucket_name}"
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
        volume {
          name = "postgres-service-account"
          secret {
            secret_name = "${kubernetes_secret.postgres-service-account.metadata.0.name}"
          }
        }
        container {
          name = "cloudsql-proxy"
          image = "gcr.io/cloudsql-docker/gce-proxy:1.11"
          command = [
            "/cloud_sql_proxy",
            "-instances=${var.gcloud_project}:${var.region}:${google_sql_database_instance.codecov.name}=tcp:5432",
            "-credential_file=/creds/postgres-credentials.json"
          ]
          security_context {
            run_as_user = "2"
            allow_privilege_escalation = "false"
          }
          volume_mount {
            name = "postgres-service-account"
            mount_path = "/creds"
            read_only = "true"
          }
        }
      }
    }
    strategy {
      type = "RollingUpdate"
    }
  }
}
