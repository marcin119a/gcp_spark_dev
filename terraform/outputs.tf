output "cluster_name" {
  description = "Nazwa klastra Dataproc"
  value       = module.dataproc.cluster_name
}

output "master_instance_name" {
  description = "Nazwa VM mastera"
  value       = module.dataproc.master_instance_name
}

output "staging_bucket" {
  description = "Bucket GCS do przesyłania jobów"
  value       = module.storage.staging_bucket_name
}

output "data_bucket" {
  description = "Bucket GCS na dane wejściowe/wyjściowe"
  value       = module.storage.data_bucket_name
}

output "spark_ui_port_forward" {
  description = "Polecenie do tunelu SSH na Spark UI (port 4040)"
  value       = "gcloud compute ssh ${module.dataproc.master_instance_name} --zone=${var.zone} -- -L 4040:localhost:4040 -L 8080:localhost:8080 -N"
}
