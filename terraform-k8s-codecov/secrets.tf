resource "kubernetes_secret" "codecov-yml" {
  metadata {
    name = "codecov-yml"
  }
  data = {
    "codecov.yml" = var.codecov_yml
  }
}
