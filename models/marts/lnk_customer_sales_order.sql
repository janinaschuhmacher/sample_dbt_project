{{
    config(
        materialized='incremental',
        unique_key='sales_order_customer_lk',
        on_schema_change='append_new_columns',
        cluster_by=['sales_order_customer_lk', 'customer_hk'],
        tags=['raw_vault', 'link']
    )
}}

WITH source_orders AS (
    select
    {{ generate_hash_key(
        ['sales_order_hk', 'customer_hk'],
        alias='sales_order_customer_lk'
    ) }},
    sales_order_hk,
    customer_hk,
    load_ts,
    record_source
from {{ ref('stg_sales_orders') }}
),

new_records AS (
    SELECT
        sales_order_customer_lk,
        customer_hk,
        sales_order_hk,
        load_ts,
        record_source,
        ROW_NUMBER() OVER (
            PARTITION BY sales_order_customer_lk
            ORDER BY load_ts ASC
        ) AS row_num
    FROM source_orders

    {% if is_incremental() %}
    WHERE sales_order_customer_lk NOT IN (
        SELECT sales_order_customer_lk FROM {{ this }}
    )
    {% endif %}
)

SELECT
    sales_order_customer_lk,
    customer_hk,
    sales_order_hk,
    load_ts,
    record_source
FROM new_records
WHERE row_num = 1