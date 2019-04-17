resource "google_redis_instance" "codecov" {
	name = "${var.redis_instance_name}"
	memory_size_gb = 1
}

resource "google_sql_database_instance" "codecov" {
  name = "${var.postgres_instance_name}"
  database_version = "POSTGRES_9_6"
  region = "${var.region}"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}

resource "random_string" "postgres-password" {
  length = "16"
  special = "true"
}

resource "google_sql_user" "codecov" {
  instance = "${google_sql_database_instance.codecov.name}"
  name = "codecov"
  password = "${random_string.postgres-password.result}"
}

resource "google_sql_database" "codecov" {
  name = "codecov"
  instance = "${google_sql_database_instance.codecov.name}"
}
