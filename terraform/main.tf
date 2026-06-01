terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    # bucket i prefix przekazywane przez -backend-config w CI (GitHub Actions)
    # lokalnie: terraform init -backend-config="bucket=<TWOJ_BUCKET>"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ─── Włącz wymagane API ───────────────────────────────────────────────────────
resource "google_project_service" "apis" {
  for_each = toset([
    "dataproc.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

# ─── Moduły ──────────────────────────────────────────────────────────────────
module "network" {
  source = "./modules/network"

  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name

  depends_on = [google_project_service.apis]
}

module "storage" {
  source = "./modules/storage"

  project_id = var.project_id
  region     = var.region
  env        = var.env

  depends_on = [google_project_service.apis]
}

module "dataproc" {
  source = "./modules/dataproc"

  project_id     = var.project_id
  region         = var.region
  env            = var.env
  cluster_name   = var.cluster_name
  master_machine = var.master_machine
  worker_machine = var.worker_machine
  num_workers    = var.num_workers
  spark_version  = var.spark_version
  subnet_self_link = module.network.subnet_self_link
  staging_bucket    = module.storage.staging_bucket_name
  service_account   = module.storage.dataproc_sa_email

  depends_on = [module.network, module.storage]
}
