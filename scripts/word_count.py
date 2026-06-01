"""
Klasyczny Word Count — przykład joba PySpark na Dataproc.
Uruchomienie: gcloud dataproc jobs submit pyspark word_count.py \
                --cluster=<nazwa> --region=<region> \
                -- gs://<bucket>/input/ gs://<bucket>/output/
"""
import sys

from pyspark.sql import SparkSession


def main(input_path: str, output_path: str) -> None:
    spark = SparkSession.builder.appName("WordCount").getOrCreate()
    sc = spark.sparkContext

    lines = sc.textFile(input_path)
    counts = (
        lines.flatMap(lambda line: line.split())
        .map(lambda word: (word.lower(), 1))
        .reduceByKey(lambda a, b: a + b)
        .sortBy(lambda pair: pair[1], ascending=False)
    )

    counts.saveAsTextFile(output_path)
    spark.stop()


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Użycie: word_count.py <input_path> <output_path>", file=sys.stderr)
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
