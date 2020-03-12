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
          persistent_volume_claim {
            claim_name = "${kubernetes_persistent_volume_claim.minio.metadata.0.name}"
          }
        }
        container {
          name  = "minio"
          image = "minio/minio:RELEASE.2019-10-02T21-19-38Z"
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

resource "kubernetes_persistent_volume" "minio" {
  metadata {
    name = "minio-nfs"
  }
  spec {
    capacity {
      storage = "${var.nfs_pv_size}"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        path = "${var.nfs_pv_path}"
        read_only = "false"
        server = "${var.nfs_pv_host}"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "minio" {
  metadata {
    name = "minio-nfs"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "${var.nfs_pv_size}"
      }
    }
    volume_name = "${kubernetes_persistent_volume.minio.metadata.0.name}"
  }
}
