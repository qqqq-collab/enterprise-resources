resource "kubernetes_secret" "codecov-yml" {
  metadata {
    name = "codecov-yml"
  }
  data {
    "codecov.yml" = "${file("${var.codecov_yml}")}"
  }
}

resource "kubernetes_secret" "minio-access-key" {
  metadata {
    name = "minio-access-key"
  }
  data {
    MINIO_ACCESS_KEY = "${var.minio_access_key}"
  }
}

resource "kubernetes_secret" "minio-secret-key" {
  metadata {
    name = "minio-secret-key"
  }
  data {
    MINIO_SECRET_KEY = "${var.minio_secret_key}"
  }
}
