with source_data as (
    select
        cast(message_id as varchar) as message_id,
        cast(message_ts as timestamp) as message_ts,
        cast(order_id as integer) as order_id,
        cast(customer_id as integer) as customer_id,
        cast(order_date as date) as order_date,
        cast(status as varchar) as status
    from {{ ref('orders') }}
),

hashed as (
    select 
        {{generate_hash_key(['order_id'], alias='sales_order_hk') }},
        {{generate_hash_key(['customer_id'], alias='customer_hk') }},
        message_id,
        message_ts,
        order_id,
        customer_id,
        order_date,
        status,
        current_timestamp as load_ts,
        'raw_orders' as record_source
    from source_data
)

select distinct * from hashed
