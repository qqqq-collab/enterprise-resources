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

resource "google_sql_database" "codecov" {
  name = "codecov"
  instance = "${google_sql_database_instance.codecov.name}"
  depends_on = ["google_sql_user.codecov"]
}
