with source_data as (
    select
        cast(message_id as varchar) as message_id,
        cast(order_id as integer) as order_id,
        cast(customer_id as integer) as customer_id,
        cast(order_date as date) as order_date,
        cast(status as varchar) as status
    from {{ ref('orders') }}
),

hashed as (
    select 
        md5(cast(order_id as varchar)) as hk_sales_order_h,
        md5(upper(trim(cast(customer_id as varchar)))) as hub_customer_hk,
        md5(concat_ws('||',
            coalesce(cast(order_date as varchar), ''),
            coalesce(status, '')
        )) as hash_diff,
        order_id,
        message_id,
        customer_id,
        order_date,
        status,
        current_timestamp as load_ts,
        'raw_orders' as record_source
    from source_data
)

select distinct * from hashed
