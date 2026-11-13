-- models/raw_vault/hubs/hub_customer.sql
{{
    config(
        materialized='incremental',
        unique_key='customer_hk',
        on_schema_change='append_new_columns',
        cluster_by=['customer_hk'],
        tags=['raw_vault', 'hub']
    )
}}

WITH source_data AS (
    SELECT
        customer_hk,
        customer_id,
        load_ts,
        record_source
    FROM {{ ref('stg_customers') }}
),

-- In an incremental run, only consider new business keys
deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_hk
            ORDER BY load_ts ASC
        ) AS row_num
    FROM source_data

    {% if is_incremental() %}
    WHERE customer_hk NOT IN (
        SELECT customer_hk FROM {{ this }}
    )
    {% endif %}
)

SELECT
    customer_hk,
    customer_id,
    load_ts,
    record_source
FROM deduped
WHERE row_num = 1