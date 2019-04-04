## Google Kubernetes Engine cluster and Node pool

## Cluster ##
# 
# It is recommended to avoid using the default node pool with terraform
# because some node pool changes will force recreation of the cluster.
# See the terraform docs for more info:
# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "primary" {
	name     = "${var.cluster_name}"
	location = "${var.region}"

	# We can't create a cluster with no node pool defined, but we want to only use
	# separately managed node pools. So we create the smallest possible default
	# node pool and immediately delete it.
	remove_default_node_pool = true
	initial_node_count = 1


	# Setting an empty username and password explicitly disables basic auth
	master_auth {
		username = ""
		password = ""
	}
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
	name = "default-pool"
	location = "${var.region}"
	cluster = "${google_container_cluster.primary.name}"
	node_count = "${var.node_pool_count}"

	node_config {
		preemptible = true
		machine_type = "${var.node_pool_machine_type}"

		metadata {
			disable-legacy-endpoints = "true"
		}

		oauth_scopes = [
			"https://www.googleapis.com/auth/logging.write",
			"https://www.googleapis.com/auth/monitoring",
		]
	}
}
