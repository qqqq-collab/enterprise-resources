module "codecov" {
  source = "../terraform-k8s-codecov"
  config_context = "kubernetes-admin@kubernetes"
  web_replicas = "2"
  codecov_url = "${var.codecov_url}"
  enterprise_license = "${var.enterprise_license}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  database_host = "${var.database_host}"
  redis_host = "${var.redis_host}"
  gcs_credentials_json = "${var.gcs_credentials_json}"
  minio_access_key = "${var.minio_access_key}"
  minio_secret_key = "${var.minio_secret_key}"
}
