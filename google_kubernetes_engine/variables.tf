variable "region" {
	description = "Google cloud region"
	default = "us-east-4"
}

variable "zone" {
	description = "Default Google cloud zone for zone-specific services"
	default = "us-east-4a"
}

variable "cluster_name" {
	description = "Google Kubernetes Engine (GKE) cluster name"
	default = "default-codecov-cluster"
}

variable "node_pool_count" {
	description = "Number of nodes to create in the default node pool"
	default = "3"
}

variable "node_pool_machine_type" {
	description = "Machine type to use for the default node pool"
	default = "n1-standard-1"
}
