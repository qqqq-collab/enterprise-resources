provider "kubernetes" {
  config_context = "${var.config_context}"
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
        volume {
          name = "codecov-yml"
          secret {
            secret_name = "${kubernetes_secret.codecov-yml.metadata.0.name}"
          }
        }
        container {
          name  = "web"
          image = "codecov/enterprise:v4.4.4"
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
              path = "/"
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

resource "kubernetes_deployment" "minio_storage" {
  metadata {
    name = "minio"
  }
  spec {
    replicas = "${var.minio_replicas}"
    selector {
      match_labels {
        app = "minio-storage"
      }
    }
    template {
      metadata {
        labels {
          app = "minio-storage"
        }
      }
      spec {
        volume {
          name = "storage"
        }
        container {
          name  = "minio"
          image = "minio/minio:RELEASE.2019-04-09T01-22-30Z"
          args  = ["gateway", "nas", "/storage"]
          port {
            container_port = 9000
          }
          env {
            name = "MINIO_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = "minio-access-key"
                key  = "MINIO_ACCESS_KEY"
              }
            }
          }
          env {
            name = "MINIO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name = "minio-secret-key"
                key  = "MINIO_SECRET_KEY"
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
          liveness_probe {
            http_get {
              path = "/minio/health/live"
              port = "9000"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          readiness_probe {
            http_get {
              path = "/minio/health/live"
              port = "9000"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          volume_mount {
            name       = "storage"
            read_only  = "false"
            mount_path = "/storage"
          }
        }
      }
    }
    strategy {
      type = "Recreate"
    }
  }
}
