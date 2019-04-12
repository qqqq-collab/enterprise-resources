variable "codecov_yml" {
  description = "codecov_yml"
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
  default = ""
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
  default = ""
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
