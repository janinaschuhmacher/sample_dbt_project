with source_data as (
    select
        cast(customer_id as integer) as customer_id,
        cast(signup_date as date) as signup_date,
        upper(country) as country
    from {{ ref('customers') }}
),

hashed as (
    select
        md5(upper(trim(cast(customer_id as varchar)))) as hub_customer_hk,
        md5(concat_ws('||',
            coalesce(cast(signup_date as varchar), ''),
            coalesce(country, '')
        )) as hash_diff,
        customer_id,
        signup_date,
        country,
        current_timestamp as load_ts,
        'raw_customers' as record_source
    from source_data
)

select distinct * from hashed