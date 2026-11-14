with source_data as (
    select
        cast(customer_id as integer) as customer_id,
        cast(signup_date as date) as signup_date,
        upper(country) as country
    from {{ ref('customers') }}
),

hashed as (
    select
        {{ generate_hash_key(['customer_id'], alias='customer_hk') }},
        customer_id,
        signup_date,
        country,
        current_timestamp as load_ts,
        'raw_customers' as record_source
    from source_data
)

select distinct * from hashed
