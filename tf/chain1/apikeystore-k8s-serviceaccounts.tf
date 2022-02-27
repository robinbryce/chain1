resource "kubernetes_service_account_v1" "apikeystore-reader-sa" {
  metadata {
    name = "apikeystore-reader-sa"
    namespace = "${var.apikeystore_namespace}"
    annotations = {
      "iam.gke.io/gcp-service-account" = "apikeystore-reader-sa@${local.gcp_project_id}.iam.gserviceaccount.com"
    }
  }
}

resource "kubernetes_service_account_v1" "apikeystore-writer-sa" {
  metadata {
    name = "apikeystore-writer-sa"
    namespace = "${var.apikeystore_namespace}"
    annotations = {
      "iam.gke.io/gcp-service-account" = "apikeystore-writer-sa@${local.gcp_project_id}.iam.gserviceaccount.com"
    }
  }
}
