module "codecov" {
  source = "../terraform-k8s-codecov"
  config_context = "kubernetes-admin@kubernetes"
  web_replicas = "2"
  worker_replicas = "2"
  minio_replicas = "4"
  codecov_yml = "${var.codecov_yml}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  database_host = "${var.database_host}"
  redis_host = "${var.redis_host}"
  minio_access_key = "${var.minio_access_key}"
  minio_secret_key = "${var.minio_secret_key}"
}
