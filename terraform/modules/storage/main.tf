locals {
  # suffix losowy, żeby nazwy bucketów były globalnie unikalne
  suffix = substr(md5("${var.project_id}-${var.env}"), 0, 6)
}

# Bucket na staging (jary, logi jobów)
resource "google_storage_bucket" "staging" {
  name          = "spark-staging-${var.env}-${local.suffix}"
  project       = var.project_id
  location      = var.region
  force_destroy = true # wygodne w środowisku szkoleniowym

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition { age = 7 }
    action { type = "Delete" }
  }
}

# Bucket na dane (input / output)
resource "google_storage_bucket" "data" {
  name          = "spark-data-${var.env}-${local.suffix}"
  project       = var.project_id
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

# Service Account dla Dataproc
resource "google_service_account" "dataproc_sa" {
  account_id   = "dataproc-sa-${var.env}"
  display_name = "Dataproc Service Account (${var.env})"
  project      = var.project_id
}

# Uprawnienia SA do bucketów
resource "google_storage_bucket_iam_member" "staging_admin" {
  bucket = google_storage_bucket.staging.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.dataproc_sa.email}"
}

resource "google_storage_bucket_iam_member" "data_admin" {
  bucket = google_storage_bucket.data.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.dataproc_sa.email}"
}

# Dataproc Worker — SA musi mieć tę rolę na poziomie projektu
resource "google_project_iam_member" "dataproc_worker" {
  project = var.project_id
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.dataproc_sa.email}"
}
