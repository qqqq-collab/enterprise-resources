resource "google_redis_instance" "codecov" {
	name = "${var.redis_instance_name}"
	memory_size_gb = 1
}

resource "random_pet" "postgres" {
  length = "2"
  separator = "-"
}

resource "google_sql_database_instance" "codecov" {
  name = "${var.postgres_instance_name}-${random_pet.postgres.id}"
  database_version = "POSTGRES_9_6"
  region = "${var.region}"

  settings {
    tier = "db-f1-micro"
  }
}

resource "random_string" "postgres-password" {
  length = "16"
  special = "false"
}

resource "google_sql_user" "codecov" {
  instance = "${google_sql_database_instance.codecov.name}"
  name = "codecov"
  password = "${random_string.postgres-password.result}"
}

# TODO destroying this resource fails because GCP refuses to destroy user above
# while it still owns db resources.  For now, if you need to destroy the entire
# stack, either remove the database instance manually, or remove the tf state for
# the above user to allow the db instance to be destroyed.
# ex: 
# terraform state rm google_sql_user.codecov
# terraform destroy
resource "google_sql_database" "codecov" {
  name = "codecov"
  instance = "${google_sql_database_instance.codecov.name}"
  depends_on = ["google_sql_user.codecov"]
}
