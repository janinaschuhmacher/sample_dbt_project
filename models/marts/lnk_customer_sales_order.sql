{{
    config(
        materialized='incremental',
        unique_key='customer_order_hk',
        on_schema_change='append_new_columns',
        cluster_by=['customer_order_hk', 'customer_hk'],
        tags=['raw_vault', 'link']
    )
}}

WITH source_orders AS (
    select
    {{ generate_hash_key(
        ['sales_order_hk', 'customer_hk'],
        alias='sales_order_customer_lhk'
    ) }},
    sales_order_hk,
    customer_hk,
    load_ts,
    record_source
from {{ ref('stg_sales_orders') }}
),

new_records AS (
    SELECT
        customer_order_hk,
        customer_hk,
        order_hk,
        load_dts,
        record_source,
        ROW_NUMBER() OVER (
            PARTITION BY customer_order_hk
            ORDER BY load_dts ASC
        ) AS row_num
    FROM source_orders

    {% if is_incremental() %}
    WHERE customer_order_hk NOT IN (
        SELECT customer_order_hk FROM {{ this }}
    )
    {% endif %}
)

SELECT
    customer_order_hk,
    customer_hk,
    order_hk,
    load_dts,
    record_source
FROM new_records
WHERE row_num = 1