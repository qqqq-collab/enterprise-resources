variable "config_context" {
  description = "kubectl config context used to connect to the target cluster"
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
  description = "Hostname used for http(s) ingress"
}

variable "traefik_replicas" {
  description = "Number of traefik replicas to deploy"
  default = "2"
}

variable "enable_https" {
  description = "Enables https ingress.  Requires TLS cert and key"
  default = "0"
}

variable "tls_key" {
  description = "Path to private key to use for TLS"
  default = ""
}

variable "tls_cert" {
  description = "Path to certificate to use for TLS"
  default = ""
}

variable "codecov_yml" {
  description = "Location of your codecov.yml file"
}

variable "nfs_pv_host" {
  description = "Host for NFS persistent volume"
}

variable "nfs_pv_path" {
  description = "Export path for NFS persistent volume"
}

variable "nfs_pv_size" {
  description = "NFS persistent volume size"
}

variable "minio_access_key" {
  description = "Access key for minio"
  default = ""
}

variable "minio_secret_key" {
  description = "Secret key for minio"
  default = ""
}
