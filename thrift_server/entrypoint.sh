#!/usr/bin/env bash
set -euo pipefail

# Required env:
#   SPARK_ENGINE            delta | iceberg
#   HIVE_URI                e.g. 172.26.242.248:9083   (no thrift:// prefix here)
#   LAKEHOUSE_BUCKET        e.g. lakehouse
#   S3_ENDPOINT_URL         e.g. http://172.26.242.248:9000
#   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
# Optional:
#   SPARK_EXTRA_CONF        extra --conf lines (newline or comma separated)
#   SPARK_MASTER            default local[*]
#   SPARK_THRIFT_NAME       default "Thrift JDBC/ODBC Server"
#   SPARK_THRIFT_PORT       default 10000

SPARK_ENGINE="${SPARK_ENGINE:-delta}"
SPARK_MASTER="${SPARK_MASTER:-local[*]}"
SPARK_THRIFT_NAME="${SPARK_THRIFT_NAME:-Thrift JDBC/ODBC Server}"
SPARK_THRIFT_PORT="${SPARK_THRIFT_PORT:-10000}"

HMS_URI="thrift://${HIVE_URI}"

COMMON_CONF=(
    --conf spark.hadoop.hive.metastore.uris="${HMS_URI}"
    --conf spark.sql.warehouse.dir="s3a://${LAKEHOUSE_BUCKET}/warehouse"
    --conf spark.hadoop.fs.s3a.endpoint="${S3_ENDPOINT_URL}"
    --conf spark.hadoop.fs.s3a.access.key="${AWS_ACCESS_KEY_ID}"
    --conf spark.hadoop.fs.s3a.secret.key="${AWS_SECRET_ACCESS_KEY}"
    --conf spark.hadoop.fs.s3a.path.style.access=true
    --conf spark.hadoop.fs.s3a.connection.ssl.enabled=false
)

ENGINE_CONF=()
case "$SPARK_ENGINE" in
    delta)
        ENGINE_CONF+=(
        --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension
        --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog
        )
        ;;
    iceberg)
        # Use Iceberg as the *session* catalog (HMS-backed)
        ENGINE_CONF+=(
        --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions
        --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog
        --conf spark.sql.catalog.spark_catalog.type=hive
        --conf spark.sql.catalog.spark_catalog.uri="${HMS_URI}"
        )
        ;;
    *)
        echo "Unknown SPARK_ENGINE='$SPARK_ENGINE' (expected 'delta' or 'iceberg')" >&2
        exit 1
        ;;
esac

# Allow arbitrary extra conf lines via env; supports newline or comma separated
if [[ -n "${SPARK_EXTRA_CONF:-}" ]]; then
    # Split on newline or comma
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        ENGINE_CONF+=( --conf "$line" )
    done < <(echo -e "${SPARK_EXTRA_CONF//,/\\n}")
fi

# Optional: start a (mostly unused) standalone master for compatibility
/opt/spark/sbin/start-master.sh --host 0.0.0.0 --port 7077 || true
sleep 5

exec /opt/spark/bin/spark-submit \
    --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
    --master "${SPARK_MASTER}" \
    --name "${SPARK_THRIFT_NAME} (${SPARK_ENGINE})" \
    --conf hive.server2.thrift.port="${SPARK_THRIFT_PORT}" \
    "${COMMON_CONF[@]}" \
    "${ENGINE_CONF[@]}" \
    --jars /home/ivy2/jars/* \
    spark-internal
