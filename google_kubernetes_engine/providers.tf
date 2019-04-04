provider "google" {
	project = "codecov-enterprise-sandbox"
	region = "${var.region}"
	zone = "${var.zone}"
}
