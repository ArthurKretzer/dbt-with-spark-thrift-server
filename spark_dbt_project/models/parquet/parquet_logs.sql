{{ config(
    materialized='table',
    schema='default',
    file_format='parquet'
) }}

select 'ok' as status, current_timestamp() as ts
