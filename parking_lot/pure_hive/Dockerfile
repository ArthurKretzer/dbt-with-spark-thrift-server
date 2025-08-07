# see <https://jdbc.postgresql.org/download.html#current>
FROM spark:3.5.4

ARG POSTGRES_CONNECTOR_VERSION=42.7.3

ENV DATABASE_DRIVER=org.postgresql.Driver
ENV DATABASE_TYPE=postgres
ENV DATABASE_TYPE_JDBC=postgresql
ENV DATABASE_PORT=5432

USER root
RUN mkdir /home/ivy2/ && chown -R spark:spark /home/ivy2
RUN mkdir /home/spark/ && chown -R spark:spark /home/spark
RUN mkdir /home/spark/conf && chown -R spark:spark /home/spark/conf
USER spark

ENV SPARK_CONF_DIR=/home/spark/conf
COPY ./config/spark-defaults.conf /home/spark/conf/
ENV SPARK_DIST_CLASSPATH="/home/ivy2/jars/*"

COPY ./download_jars.sh /home/
RUN /home/download_jars.sh

COPY entrypoint.sh /entrypoint.sh

USER root
RUN chmod +x /entrypoint.sh
USER spark

ENTRYPOINT ["/entrypoint.sh"]
