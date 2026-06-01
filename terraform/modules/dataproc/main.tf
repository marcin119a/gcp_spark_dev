resource "google_dataproc_cluster" "spark" {
  name    = var.cluster_name
  project = var.project_id
  region  = var.region

  labels = {
    env     = var.env
    purpose = "training"
  }

  cluster_config {
    staging_bucket = var.staging_bucket

    # ── Master node ──────────────────────────────────────────────────────────
    master_config {
      num_instances = 1
      machine_type  = var.master_machine

      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 50
      }
    }

    # ── Worker nodes ─────────────────────────────────────────────────────────
    worker_config {
      num_instances = var.num_workers
      machine_type  = var.worker_machine

      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 50
      }
    }

    # ── Sieć (bez external IP — bezpieczniej) ────────────────────────────────
    gce_cluster_config {
      subnetwork       = var.subnet_self_link
      service_account  = var.service_account
      internal_ip_only = true # brak publicznego IP na węzłach

      tags = ["dataproc-node"]

      service_account_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
    }

    # ── Obraz Dataproc (wersja Spark / Hadoop) ───────────────────────────────
    software_config {
      image_version = var.spark_version

      # Właściwości Spark dostrojone pod mini-klaster szkoleniowy
      override_properties = {
        "spark:spark.executor.memory"          = "2g"
        "spark:spark.driver.memory"            = "2g"
        "spark:spark.executor.cores"           = "1"
        "spark:spark.dynamicAllocation.enabled" = "true"
        "spark:spark.shuffle.service.enabled"  = "true"
        "dataproc:dataproc.allow.zero.workers" = "false"
      }
    }

    # ── Auto-wyłączenie klastra po czasie nieaktywności ──────────────────────
    # Ważne w szkoleniach — zapobiega zapomnianym kosztom
    lifecycle_config {
      idle_delete_ttl = "3600s" # wyłącz po 1 h bezczynności
    }
  }
}
