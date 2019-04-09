data "template_file" "codecov-yml" {
  template = "${file("${path.module}/templates/codecov.yml.tpl")}"
  vars = {
    # setup
    codecov_url = "${var.codecov_url}"
    enterprise_license = "${var.enterprise_license}"
    guest_access = "${var.guest_access}"
    cookie_secret = "${var.cookie_secret}"

    # linked service providers
    github_client_id = "${var.github_client_id}"
    github_client_secret = "${var.github_client_secret}"
    github_global_upload_token = "${var.github_global_upload_token}"
    github_enterprise_url = "${var.github_enterprise_url}"
    github_enterprise_api_url = "${var.github_enterprise_api_url}"
    github_enterprise_client_id = "${var.github_enterprise_client_id}"
    github_enterprise_client_secret = "${var.github_enterprise_client_secret}"
    github_enterprise_global_upload_token = "${var.github_enterprise_global_upload_token}"
    bitbucket_client_id = "${var.bitbucket_client_id}"
    bitbucket_client_secret = "${var.bitbucket_client_secret}"
    bitbucket_global_upload_token = "${var.bitbucket_global_upload_token}"
    bitbucket_server_url = " ${var.bitbucket_server_url}"
    bitbucket_server_client_id = "${var.bitbucket_server_client_id}"
    bitbucket_server_global_upload_token = "${var.bitbucket_server_global_upload_token}"
    gitlab_enterprise_url = "${var.gitlab_enterprise_url}"
    gitlab_enterprise_client_id = "${var.gitlab_enterprise_client_id}"
    gitlab_enterprise_client_secret = "${var.gitlab_enterprise_client_secret}"
    gitlab_enterprise_ssl_pem = "${var.gitlab_enterprise_ssl_pem}"
    gitlab_enterprise_global_upload_token = "${var.gitlab_enterprise_global_upload_token}"

    # codecov services
    ci_providers = "${var.ci_providers}"
    database_username = "${var.database_username}"
    database_password = "${var.database_password}"
    database_host = "${var.database_host}"
    database_port = "${var.database_port}"
    database_name = "${var.database_name}"
    redis_username = "${var.redis_username}"
    redis_password = "${var.redis_password}"
    redis_host = "${var.redis_host}"
    redis_port = "${var.redis_port}"
    redis_name = "${var.redis_name}"
  }
}

resource "kubernetes_secret" "codecov-yml" {
  metadata {
    name = "codecov-yml"
  }
  data {
    "codecov.yml" = "${data.template_file.codecov-yml.rendered}"
  }
}

resource "kubernetes_secret" "gcs-credentials" {
  metadata {
    name = "gcs-credentials"
  }
  data {
    "gcs-credentials.json" = "${file("${var.gcs_credentials_json}")}"
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
