#!/usr/bin/env bash
# Przykład: uruchomienie joba PySpark na klastrze Dataproc
# Użycie: ./scripts/submit_job.sh <project_id> <region> <cluster_name> <data_bucket>

set -euo pipefail

PROJECT_ID="${1:?Podaj project_id}"
REGION="${2:-europe-central2}"
CLUSTER="${3:-spark-training-cluster}"
DATA_BUCKET="${4:?Podaj nazwę bucketu danych}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Wgraj skrypt PySpark do bucketu
echo "==> Wgrywanie skryptu word_count.py do gs://${DATA_BUCKET}/scripts/"
gsutil cp "${SCRIPT_DIR}/word_count.py" "gs://${DATA_BUCKET}/scripts/word_count.py"

# Wgraj przykładowy plik wejściowy
echo "==> Wgrywanie danych wejściowych..."
echo "Hello Spark Hello GCP DevOps Training Hello World" \
  | gsutil cp - "gs://${DATA_BUCKET}/input/sample.txt"

# Uruchom job
echo "==> Uruchamianie joba Spark..."
gcloud dataproc jobs submit pyspark \
  "gs://${DATA_BUCKET}/scripts/word_count.py" \
  --cluster="${CLUSTER}" \
  --region="${REGION}" \
  --project="${PROJECT_ID}" \
  -- \
  "gs://${DATA_BUCKET}/input/sample.txt" \
  "gs://${DATA_BUCKET}/output/word_count_$(date +%Y%m%d_%H%M%S)"

echo "==> Job zakończony. Wyniki w gs://${DATA_BUCKET}/output/"
