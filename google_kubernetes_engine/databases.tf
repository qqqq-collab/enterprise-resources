resource "google_redis_instance" "codecov" {
  name = "${var.redis_instance_name}"
  memory_size_gb = 1
}

# This is necessary due to google_sql_database instance names being eventually
# consistent.  For tasks that require recreation of the db resource, using the 
# same name often fails because it remains reserved until the record of the db
# instance is fully purged from google's metadata.
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

# Destroying this resource fails because GCP refuses to destroy user above
# while it still owns db resources.  For now, we have provided a destroy.sh script
# that removes the above user from state to allow the db instance to be destroyed.
resource "google_sql_database" "codecov" {
  name = "codecov"
  instance = "${google_sql_database_instance.codecov.name}"
  depends_on = ["google_sql_user.codecov"]
}
