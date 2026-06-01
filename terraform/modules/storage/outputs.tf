output "staging_bucket_name" {
  value = google_storage_bucket.staging.name
}

output "data_bucket_name" {
  value = google_storage_bucket.data.name
}

output "dataproc_sa_email" {
  value = google_service_account.dataproc_sa.email
}
