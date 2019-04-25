provider "aws" {
  region = "${var.region}"
}

# TODO document KUBECONFIG env var setup
provider "kubernetes" { }
