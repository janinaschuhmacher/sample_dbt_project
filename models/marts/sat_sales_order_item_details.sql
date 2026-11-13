{{ config(materialized='incremental') }}

with source_data as (
    select
        *
    from {{ ref('stg_sales_order_items') }}
)

select
    sales_order_position_item_hk,
    {{generate_hash_key(['product_id', 'quantity', 'unit_price', 'line_amount'], alias='hash_diff') }},
    message_id,
    message_ts,
    order_id,
    order_position,
    product_id, 
    quantity, 
    unit_price, 
    line_amount,
    load_ts,
    record_source
from source_data