#!/bin/bash

set -euxo pipefail

generate_database_config(){
  cat << XML
<property>
  <name>javax.jdo.option.ConnectionDriverName</name>
  <value>${DATABASE_DRIVER}</value>
</property>
<property>
  <name>javax.jdo.option.ConnectionURL</name>
  <value>jdbc:${DATABASE_TYPE_JDBC}://${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}</value>
</property>
<property>
  <name>javax.jdo.option.ConnectionUserName</name>
  <value>${DATABASE_USER}</value>
</property>
<property>
  <name>javax.jdo.option.ConnectionPassword</name>
  <value>${DATABASE_PASSWORD}</value>
</property>
XML
}

generate_hive_site_config(){
  database_config=$(generate_database_config)
  cat << XML > "$1"
<configuration>
$database_config
</configuration>
XML
}

# configure

set +x
generate_hive_site_config /home/spark/conf/hive-site.xml
set -x

/opt/spark/bin/spark-submit \
  --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
  --name "Thrift JDBC/ODBC Server" \
  --conf spark.sql.catalogImplementation=hive \
  --conf hive.aux.jars.path=file:///home/ivy2/jars \
  --conf spark.sql.warehouse.dir=s3a://$LAKEHOUSE_BUCKET/ \
  --conf spark.hadoop.hive.metastore.uris=thrift://$HIVE_URI \
  --conf spark.hadoop.fs.s3a.endpoint=$S3_ENDPOINT_URL \
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
