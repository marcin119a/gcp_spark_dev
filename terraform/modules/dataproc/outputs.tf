output "cluster_name" {
  value = google_dataproc_cluster.spark.name
}

output "master_instance_name" {
  value = "${google_dataproc_cluster.spark.name}-m"
}
