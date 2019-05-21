resource "google_service_account" "postgres" {
  account_id   = "codecov-postgres"
  display_name = "Codecov postgres"
}

resource "google_service_account_key" "postgres" {
  service_account_id = "${google_service_account.postgres.name}"
}

resource "google_project_iam_member" "postgres" {
  project = "${var.gcloud_project}"
  role = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.postgres.email}"
}

resource "kubernetes_secret" "postgres-service-account" {
  metadata = {
    name = "postgres-service-account"
  }
  data {
    "postgres-credentials.json" = "${base64decode(google_service_account_key.postgres.private_key)}"
  }
}

resource "google_service_account" "minio" {
  account_id   = "codecov-minio"
  display_name = "Codecov minio"
}

resource "google_service_account_key" "minio" {
  service_account_id = "${google_service_account.minio.name}"
}

resource "google_project_iam_member" "minio" {
  project = "${var.gcloud_project}"
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.minio.email}"
}

resource "kubernetes_secret" "minio-service-account" {
  metadata = {
    name = "minio-service-account"
  }
  data {
    "minio-credentials.json" = "${base64decode(google_service_account_key.minio.private_key)}"
  }
}

resource "kubernetes_service_account" "traefik_ingress_controller" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role_binding" "traefik_ingress_controller" {
  metadata {
    name = "traefik-ingress-controller"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.traefik_ingress_controller.metadata.0.name}"
    namespace = "${kubernetes_service_account.traefik_ingress_controller.metadata.0.namespace}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    # giving cluster-admin is too much access for traefik.
    name      = "cluster-admin"
  }
}
