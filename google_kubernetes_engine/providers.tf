provider "google" {
  version = "~>3.21"
  project = var.gcloud_project
  region  = var.region
  zone    = var.zone
}

provider "kubernetes" {
  version          = "~>1.11"
  load_config_file = "false"
  host             = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
  token = data.google_client_config.current.access_token
}

provider "null" {
  version = "~>2.1"
}

provider "random" {
  version = "~>2.2"
}

provider "template" {
  version = "~>2.1"
}
