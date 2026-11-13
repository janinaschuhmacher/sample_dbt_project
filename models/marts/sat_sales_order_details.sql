{{ config(materialized='incremental') }}

with source_data as (
    select
        *
    from {{ ref('stg_sales_orders') }}
)

select
    sales_order_hk,
    {{generate_hash_key(['order_date', 'status'], alias='hash_diff') }},
    message_id,
    message_ts,
    order_id,
    order_date,
    status,
    load_ts,
    record_source
from source_data