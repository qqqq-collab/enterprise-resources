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
    replicas = 2
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

resource "kubernetes_deployment" "minio_gcs_proxy" {
  metadata {
    name = "minio-gcs-proxy"
  }
  spec {
    replicas = 2
    selector {
      match_labels {
        app = "minio-gcs-proxy"
      }
    }
    template {
      metadata {
        labels {
          app = "minio-gcs-proxy"
        }
      }
      spec {
        volume {
          name = "gcs-credentials"
          secret {
            secret_name = "${kubernetes_secret.gcs-credentials.metadata.0.name}"
          }
        }
        container {
          name  = "minio"
          image = "minio/minio:RELEASE.2018-07-23T18-34-49Z"
          args  = ["gateway", "gcs", "codecov-enterprise-sandbox"]
          port {
            container_port = 9000
          }
          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/credentials/gcs-credentials.json"
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
            name       = "gcs-credentials"
            read_only  = "true"
            mount_path = "/etc/credentials"
          }
        }
      }
    }
    strategy {
      type = "Recreate"
    }
  }
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name = "traefik"
  }
  spec {
    replicas = 2
    selector {
      match_labels {
        app = "traefik"
      }
    }
    template {
      metadata {
        labels {
          app = "traefik"
        }
      }
      spec {
        container {
          name  = "traefik"
          image = "traefik:v1.7-alpine"
          args = [
            "--entryPoints=Name:http Address::80 Compress::true",
            "--defaultEntryPoints=http"
          ]
          port {
            container_port = 80
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
        }
      }
    }
    strategy {
      type = "Recreate"
    }
  }
}
