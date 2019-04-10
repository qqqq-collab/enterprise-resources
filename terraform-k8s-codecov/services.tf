
resource "kubernetes_service" "minio_gcs_proxy" {
  metadata {
    name = "minio-gcs-proxy"
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 9000
      target_port = "9000"
    }
    selector {
      app = "minio-gcs-proxy"
    }
  }
}

