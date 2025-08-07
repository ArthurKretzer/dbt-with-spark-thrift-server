/usr/bin/mc alias set myminio http://storage:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD && \
/usr/bin/mc --insecure mb --ignore-existing myminio/lakehouse