# -----------------------------------------------------------------------------
# workload identity & iam for the apikeystore
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# READER gets to read any document in firestore from the apikeystore namespace
# -----------------------------------------------------------------------------
resource "google_service_account" "apikeystore_reader" {
  account_id   = "apikeystore-reader-sa"
  display_name = substr("Workload Identity ${local.workloadid_fqdn}[${var.apikeystore_namespace}/apikeystore-reader-sa]", 0, 100)
  project      = local.gcp_project_id
}

resource "google_service_account_iam_member" "apikeystore_reader" {
  service_account_id = google_service_account.apikeystore_reader.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "${local.workloadid_fqdn}[${var.apikeystore_namespace}/apikeystore-reader-sa]"
}

resource "google_service_account" "apikeystore_writer" {
  account_id   = "apikeystore-writer-sa"
  display_name = substr("Workload Identity ${local.workloadid_fqdn}[${var.apikeystore_namespace}/apikeystore-writer-sa]", 0, 100)
  project      = local.gcp_project_id
}

# -----------------------------------------------------------------------------
# READER role
# -----------------------------------------------------------------------------
resource "google_project_iam_custom_role" "apikeystore_reader" {
  role_id = "apikeystore_reader"
  title   = "Document Reader Role"

  project    = local.gcp_project_id

  permissions = [
    # XXX: these are currently just the defaults for the roles/datastore.viewer.
    # TOOD try to reduce them
    "appengine.applications.get",
    "datastore.databases.get",
    "datastore.entities.get",
    "datastore.entities.list",
    "datastore.indexes.get",
    "datastore.indexes.list",
    "datastore.namespaces.get",
    "datastore.namespaces.list",
    "datastore.statistics.get",
    "datastore.statistics.list",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list"
  ]
}

# Add the Document Reader Role to the apikeystore_reader workload identity
resource "google_project_iam_member" "apikeystore_reader" {

  depends_on = [google_project_iam_custom_role.apikeystore_reader]
  project = local.gcp_project_id
  role = "projects/${local.gcp_project_id}/roles/apikeystore_reader"
  member = "serviceAccount:${google_service_account.dns["apikeystore_reader"].email}"
}

# -----------------------------------------------------------------------------
# WRITER gets to read any document in firestore from the apikeystore namespace
# -----------------------------------------------------------------------------

resource "google_service_account_iam_member" "apikeystore_writer" {

  service_account_id = google_service_account.apikeystore_writer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "${local.workloadid_fqdn}[${var.apikeystore_namespace}/apikeystore-writer-sa]"
}

# provided so we can have write access for tracking usage metrics of keys independently
# of the write access required to update or delete the keys.
resource "google_service_account" "apikeystore_keymetrics" {
  account_id   = "apikeystore-keymetrics-sa"
  display_name = substr("Workload Identity ${local.workloadid_fqdn}[${var.apikeystore_namespace}/apikeystore-keymetrics-sa]", 0, 100)
  project      = local.gcp_project_id
}

# -----------------------------------------------------------------------------
# Writer role
# -----------------------------------------------------------------------------

resource "google_project_iam_custom_role" "apikeystore_writer" {
  role_id = "apikeystore_writer"
  title   = "Document Writer Role"

  project    = local.gcp_project_id

  # XXX: these are currently just the defaults for the roles/datastore.user.
  # TOOD try to reduce them

  permissions = [
    "appengine.applications.get",
    "datastore.databases.get",
    "datastore.entities.*",
    "datastore.indexes.list",
    "datastore.namespaces.get",
    "datastore.namespaces.list",
    "datastore.statistics.get",
    "datastore.statistics.list",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list"
  ]
}

# Add the Document Writer Role to the apikeystore_writer workload identity
resource "google_project_iam_member" "apikeystore_writer" {

  depends_on = [google_project_iam_custom_role.apikeystore_writer]
  project = local.gcp_project_id
  role = "projects/${local.gcp_project_id}/roles/apikeystore_writer"
  member = "serviceAccount:${google_service_account.dns["apikeystore_writer"].email}"
}
