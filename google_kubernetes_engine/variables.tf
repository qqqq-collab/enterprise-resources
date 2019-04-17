variable "gcloud_project" {
  description = "Google cloud project"
}

variable "region" {
  description = "Google cloud region"
  default = "us-east4"
}

variable "zone" {
  description = "Default Google cloud zone for zone-specific services"
  default = "us-east4a"
}

variable "cluster_name" {
  description = "Google Kubernetes Engine (GKE) cluster name"
  default = "default-codecov-cluster"
}

variable "web_node_pool_count" {
  description = "Number of nodes to create in the default node pool"
  default = "1"
}

variable "worker_node_pool_count" {
  description = "Number of nodes to create in the default node pool"
  default = "1"
}

variable "minio_node_pool_count" {
  description = "Number of nodes to create in the default node pool"
  default = "1"
}

variable "node_pool_machine_type" {
  description = "Machine type to use for the default node pool"
  default = "n1-standard-1"
}

variable "web_replicas" {
  description = "Number of web replicas to execute"
  default = "2"
}

variable "worker_replicas" {
  description = "Number of worker replicas to execute"
  default = "2"
}

variable "minio_replicas" {
  description = "Number of minio replicas to execute"
  default = "4"
}

variable "minio_gcs_creds" {
  description = "Google cloud credentials for minio"
}

variable "minio_bucket_name" {
  description = "Name of GCS bucket to create for minio"
}

variable "minio_bucket_location" {
  description = "Name of GCS bucket to create for minio"
  default = "US"
}

variable "minio_access_key" {
  description = "Access key for minio api"
}

variable "minio_secret_key" {
  description = "Secret key for minio api"
}

variable "redis_instance_name" {
  description = "Name used for redis instance"
}

variable "postgres_instance_name" {
  description = "Name used for postgres instance"
}

variable "codecov_yml" {
  description = "Path to your codecov.yml"
  default = "codecov.yml"
}
