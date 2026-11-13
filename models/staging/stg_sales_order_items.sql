with source_data as (
    select
        cast(message_id as varchar) as message_id,
        cast(message_ts as timestamp) as message_ts,
        cast(order_id as integer) as order_id,
        cast(order_position as integer) as order_position,
        cast(product_id as integer) as product_id,
        cast(quantity as integer) as quantity,
        cast(unit_price as decimal(10,2)) as unit_price,
        cast(line_amount as decimal(10,2)) as line_amount
    from {{ ref('orders') }}
),

hashed as (
    select 
        {{generate_hash_key(['order_id', 'order_position'], alias='sales_order_position_item_hk') }},
        {{generate_hash_key(['order_id'], alias='sales_order_hk') }},
        message_id,
        message_ts,
        order_id,
        order_position,
        product_id,
        quantity,
        unit_price,
        line_amount,
        current_timestamp as load_ts,
        'raw_order_items' as record_source
    from source_data
)

select distinct * from hashed