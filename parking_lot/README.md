# Spark Thrift Server Considerations

1. Thrift server/spark session with both Iceberg and Delta catalogs

    - This will work in situations where DBT is not used.
    - `SHOW CATALOGS;` When running on the first time will only show `spark_catalog`. Iceberg catalog will only show after querying or creating an iceberg table over iceberg catalog.
    - Always use fully qualified table names considering the structure ``catalog.schema.table``
    - `USE CATALOG iceberg` will not work, don't trust LLMs on that.
    - We can't configure DBT to accept the catalog specification (``catalog.schema.table``) as stated [in the docs](https://docs.getdbt.com/reference/resource-configs/spark-configs#always-schema-never-database).

2. Pure Hive

    - Pure Hive is intended to be used with PyHive or Hive connector instead of Thrift in DBT and other tools. It was created by mistake, but may be useful in some future applications so an example was documented in `parking_lot/pure_hive`.
