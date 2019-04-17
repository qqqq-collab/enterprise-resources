variable "codecov_yml" {
  description = "codecov_yml"
  default = ""
}

variable "nfs_pv_host" {
  description = "nfs_pv_host"
  default = ""
}

variable "nfs_pv_path" {
  description = "nfs_pv_path"
  default = ""
}

variable "nfs_pv_size" {
  description = "nfs_pv_size"
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
