
variable "config_context" {
  description = "Kubernetes config context used to connect to the target cluster"
}

variable "web_replicas" {
  description = "Number of web replicas to deploy"
}

variable "codecov_url" {
  description = "codecov_url"
  default = ""
}

variable "enterprise_license" {
  description = "enterprise_license"
  default = ""
}

variable "guest_access" {
  description = "guest_access"
  default = ""
}

variable "cookie_secret" {
  description = "cookie_secret"
  default = ""
}

variable "github_client_id" {
  description = "github_client_id"
  default = ""
}

variable "github_client_secret" {
  description = "github_client_secret"
  default = ""
}

variable "github_global_upload_token" {
  description = "github_global_upload_token"
  default = ""
}

variable "github_enterprise_url" {
  description = "github_enterprise_url"
  default = ""
}

variable "github_enterprise_api_url" {
  description = "github_enterprise_api_url"
  default = ""
}

variable "github_enterprise_client_id" {
  description = "github_enterprise_client_id"
  default = ""
}

variable "github_enterprise_client_secret" {
  description = "github_enterprise_client_secret"
  default = ""
}

variable "github_enterprise_global_upload_token" {
  description = "github_enterprise_global_upload_token"
  default = ""
}

variable "bitbucket_client_id" {
  description = "bitbucket_client_id"
  default = ""
}

variable "bitbucket_client_secret" {
  description = "bitbucket_client_secret"
  default = ""
}

variable "bitbucket_global_upload_token" {
  description = "bitbucket_global_upload_token"
  default = ""
}

variable "bitbucket_server_url" {
  description = "bitbucket_server_url"
  default = ""
}

variable "bitbucket_server_client_id" {
  description = "bitbucket_server_client_id"
  default = ""
}

variable "bitbucket_server_global_upload_token" {
  description = "bitbucket_server_global_upload_token"
  default = ""
}

variable "gitlab_enterprise_url" {
  description = "gitlab_enterprise_url"
  default = ""
}

variable "gitlab_enterprise_client_id" {
  description = "gitlab_enterprise_client_id"
  default = ""
}

variable "gitlab_enterprise_client_secret" {
  description = "gitlab_enterprise_client_secret"
  default = ""
}

variable "gitlab_enterprise_ssl_pem" {
  description = "gitlab_enterprise_ssl_pem"
  default = ""
}

variable "gitlab_enterprise_global_upload_token" {
  description = "gitlab_enterprise_global_upload_token"
  default = ""
}

variable "ci_providers" {
  description = "ci_providers"
  default = ""
}

variable "database_username" {
  description = "database_username"
  default = ""
}

variable "database_password" {
  description = "database_password"
  default = ""
}

variable "database_host" {
  description = "database_host"
  default = ""
}

variable "database_port" {
  description = "database_port"
  default = "5432"
}

variable "database_name" {
  description = "database_name"
  default = "codecov"
}

variable "redis_username" {
  description = "redis_username"
  default = ""
}

variable "redis_password" {
  description = "redis_password"
  default = ""
}

variable "redis_host" {
  description = "redis_host"
  default = ""
}

variable "redis_port" {
  description = "redis_port"
  default = "6379"
}

variable "redis_name" {
  description = "redis_name"
  default = ""
}

variable "gcs_credentials_json" {
  description = "Path to json file containing google cloud credentials"
  default = ""
}

variable "minio_access_key" {
  description = "minio access key"
  default = ""
}

variable "minio_secret_key" {
  description = "minio secret key"
  default = ""
}
