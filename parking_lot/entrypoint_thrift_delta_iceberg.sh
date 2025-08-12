#!/bin/bash
# Although we can configure a spark session to have two catalogs (delta and iceberg) and a thrift server as such, we can't configure DBT to accept the catalog specification as stated [in the docs](https://docs.getdbt.com/reference/resource-configs/spark-configs#always-schema-never-database).

/opt/spark/sbin/start-master.sh --host 0.0.0.0 --port 7077 \
  && sleep 20 && \
  /opt/spark/bin/spark-submit \
    --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
    --master local[*] \
    --name "Thrift JDBC/ODBC Server" \
    --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension,org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
    --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog \
    --conf spark.sql.catalog.spark_catalog.uri=thrift://$HIVE_URI \
    --conf spark.sql.catalog.spark_catalog.warehouse=s3a://$LAKEHOUSE_BUCKET/ \
    --conf spark.sql.catalog.iceberg=org.apache.iceberg.spark.SparkCatalog \
    --conf spark.sql.catalog.iceberg.type=hive \
    --conf spark.sql.catalog.iceberg.uri=thrift://$HIVE_URI \
    --conf spark.sql.catalog.iceberg.warehouse=s3a://$LAKEHOUSE_BUCKET/ \
    --conf spark.hadoop.hive.metastore.uris=thrift://$HIVE_URI \
    --conf spark.sql.catalogImplementation=hive \
    --conf spark.sql.warehouse.dir=s3a://$LAKEHOUSE_BUCKET/ \
    --conf hive.aux.jars.path=file:///home/ivy2/jars \
    --conf spark.hadoop.fs.s3a.endpoint=$S3_ENDPOINT_URL \
    --conf spark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID \
    --conf spark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY \
    --conf spark.hadoop.fs.s3a.path.style.access=true \
    --conf spark.hadoop.fs.s3a.connection.ssl.enabled=false \
    --jars /home/ivy2/jars/* \
    spark-internal
