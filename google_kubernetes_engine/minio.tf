resource "google_storage_bucket" "minio" {
  name = "${var.minio_bucket_name}"
  location = "${var.minio_bucket_location}"
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
        node_selector {
          role = "minio"
        }
        volume {
          name = "minio-service-account"
          secret {
            secret_name = "${kubernetes_secret.minio-service-account.metadata.0.name}"
          }
        }
        container {
          name  = "minio"
          image = "minio/minio:RELEASE.2019-04-09T01-22-30Z"
          args  = ["gateway", "gcs", "${var.gcloud_project}"]
          port {
            container_port = 9000
          }
          env {
            name = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/creds/minio-credentials.json"
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
            name = "minio-service-account"
            read_only = "true"
            mount_path = "/creds"
          }
        }
      }
    }
    strategy {
      type = "Recreate"
    }
  }
}

resource "kubernetes_service" "minio" {
  metadata {
    name = "minio"
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 9000
      target_port = "9000"
    }
    selector {
      app = "minio-storage"
    }
  }
}
