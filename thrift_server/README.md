/opt/spark/bin/beeline

!connect jdbc:hive2://localhost:10000

select * from parquet.lemom_areas;

/opt/spark/sbin/start-master.sh --host 0.0.0.0 --port 7077 \
  && sleep 20 && \
  /opt/spark/bin/spark-submit \
  --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
  --name "Thrift JDBC/ODBC Server" \
  --master local[*] \
  --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension \
  --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog \
  --conf hive.aux.jars.path=file:///home/ivy2/jars \
  --conf spark.sql.warehouse.dir=s3a://lakehouse/ \
  --conf spark.hadoop.hive.metastore.uris=thrift://hive-metastore:9083 \
  --conf spark.hadoop.fs.s3a.endpoint=storage:9000 \
  --conf spark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID \
  --conf spark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY \
  --conf spark.hadoop.fs.s3a.path.style.access=true \
  --conf spark.hadoop.fs.s3a.connection.ssl.enabled=false \
  --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
  --conf spark.hadoop.fs.s3a.connection.maximum=100 \
  --conf spark.driver.memory=2g \
  --conf spark.executor.memory=2g \
  --conf spark.executor.cores=2 \
  --jars /home/ivy2/jars/*
  spark-internal
