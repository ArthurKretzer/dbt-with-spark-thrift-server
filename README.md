# Open Data Lakehouse Framework with Hive Metastore, Spark Thrift Server, and DBT

This project provides an open-source framework to build and experiment with modern data lakehouse architectures using:

- **Hive Metastore** for schema management  
- **Apache Spark Thrift Server** for distributed query execution  
- **DBT** for SQL-based transformations and model management  
- **MinIO** as a local S3-compatible object store (for development purposes)  

It is designed to help developers and data engineers bootstrap lakehouse stacks with open-source tools for local experimentation, prototyping, and education.

---

## 📚 Summary

- [Open Data Lakehouse Framework with Hive Metastore, Spark Thrift Server, and DBT](#open-data-lakehouse-framework-with-hive-metastore-spark-thrift-server-and-dbt)
  - [📚 Summary](#-summary)
  - [🌲 Repository Structure](#-repository-structure)
  - [🚀 Quick Start (Docker)](#-quick-start-docker)
  - [⚙️ Python Environment Setup (UV)](#️-python-environment-setup-uv)
  - [🔧 DBT Commands](#-dbt-commands)
  - [🧪 Connect to Spark Thrift Server with Beeline](#-connect-to-spark-thrift-server-with-beeline)
  - [📝 License](#-license)

---

## 🌲 Repository Structure

```text
.
├── hive/                       # Hive configurations and examples
│   └── example/
├── logs/                       # Spark event logs and Thrift logs
├── minio/                      # MinIO deployment configs
├── parking_lot/               # Experimental and alternative setups
│   ├── external_master/        # Spark master externalized setup
│   ├── iceberg/                # Iceberg variant (future support)
│   └── pure_hive/              # Hive-only setup with DBT
│       └── config/
├── spark_dbt_project/          # Main DBT project
│   ├── analyses/               # Ad-hoc queries
│   ├── logs/                   # DBT logs
│   ├── macros/                 # Custom Jinja macros
│   ├── models/                 # DBT models (SQL transformations)
│   │   └── example/
│   ├── seeds/                  # CSV files loaded into tables
│   ├── snapshots/              # Slowly changing dimensions (SCD) tracking
│   ├── target/                 # DBT build artifacts
│   │   ├── compiled/
│   │   │   └── spark_dbt_project/models/example/
│   │   └── run/
│   │       └── spark_dbt_project/models/example/
│   └── tests/                  # Custom schema/data tests
└── thrift_server/              # Spark Thrift Server container configs
    └── config/
```

---

## 🚀 Quick Start (Docker)

Make sure Docker and Docker Compose are installed.

```bash
cp minio/.env-example minio/.env && cp thrift_server/.env-example thrift_server/.env && cp hive/.env-example hive/.env
docker-compose up -d
```

This command will:

- Start the Spark Thrift Server
- Start Hive Metastore
- Launch MinIO (for S3-like object storage)
- You can now connect to the Thrift Server via localhost:10000 using DBT or any JDBC/ODBC client.

---

## ⚙️ Python Environment Setup (UV)

We use [Astral UV](https://github.com/astral-sh/uv) for Python version management and dependency isolation.

1. Install ``uv`` if you don't have it:

    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```

2. Install the correct Python version:

    This project uses Python 3.13. To install it via UV:

    ```bash
    uv venv --python 3.13
    ```

    Then activate the environment:

    ```bash
    source .venv/bin/activate
    ```

---

## 🔧 DBT Commands

Once your containers are running and environment is ready:

Debug the DBT connection:

```bash
dbt debug
```

Run all models:

```bash
dbt run
```

Rebuild from scratch (drops and recreates tables):

```bash
dbt run --full-refresh
```

You can edit or add models inside ``spark_dbt_project/models/`` and rerun ``dbt run``.

---

## 🧪 Connect to Spark Thrift Server with Beeline

You can manually test the Spark Thrift Server connection using Beeline, the JDBC CLI for Hive and Spark SQL.

1. Open a terminal inside the Spark Thrift Server container:

    ```bash
    docker exec -it spark-thrift /bin/bash
    ```

2. Start Beeline:

    ```bash
    /opt/spark/bin/beeline
    ```

    You should now see the ``beeline>`` prompt.

3. Connect to the Spark Thrift Server:

    ```bash
    !connect jdbc:hive2://localhost:10000
    ```

    >>If authentication is not required, just press Enter when prompted for username and password.

4. Run a simple query:

    ```bash
    select * from default.my_first_dbt_model;
    ```

---

## 📝 License

This project is open-source and licensed under the Apache 2.0 License
