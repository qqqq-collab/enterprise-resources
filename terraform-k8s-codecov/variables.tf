variable "config_context" {
  description = "Kubernetes config context used to connect to the target cluster"
}

variable "web_replicas" {
  description = "Number of web replicas to deploy"
  default = "2"
}

variable "worker_replicas" {
  description = "Number of worker replicas to deploy"
  default = "2"
}

variable "minio_replicas" {
  description = "Number of minio replicas to deploy"
  default = "2"
}

variable "ingress_host" {
  description = "Hostname used for ingress"
  default = "codecov-ingress"
}

variable "traefik_replicas" {
  description = "Number of traefik replicas to deploy"
  default = "2"
}

variable "codecov_yml" {
  description = "Location of your codecov.yml file"
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
