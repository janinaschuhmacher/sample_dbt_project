{{ config(materialized='incremental') }}

with source_data as (
    select
        customer_hk,
        customer_id,
        signup_date,
        country,
        load_ts,
        record_source
    from {{ ref('stg_customers') }}
)

select
    customer_hk,
    {{ generate_hash_key(['signup_date', 'country'], alias='hash_diff') }},
    signup_date,
    country,
    load_ts,
    record_source
from source_data