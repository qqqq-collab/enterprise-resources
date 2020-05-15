variable "codecov_version" {
  description = "Version of Codecov Enterprise to deploy"
  default = "4.4.12"
}

variable "web_replicas" {
  description = "Number of web replicas to deploy"
  default     = "2"
}

variable "worker_replicas" {
  description = "Number of worker replicas to deploy"
  default     = "2"
}

variable "codecov_yml" {
  description = "Location of your codecov.yml file"
}
