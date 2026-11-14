{{ 
    config(
        materialized='incremental',
        unique_key=['sales_order_hk', 'load_ts'],
        on_schema_change='append_new_columns',
        cluster_by=['sales_order_hk', 'load_ts'],
        tags=['raw_vault', 'satellite']
    ) 
}}

WITH source_data AS (
    SELECT *
    FROM {{ ref('stg_sales_orders') }}
),

most_recent_satellite AS (
    SELECT
        sales_order_hk,
        hash_diff AS latest_hash_diff,
        load_ts AS latest_load_ts
    FROM (
        SELECT
            sales_order_hk,
            hash_diff,
            load_ts,
            ROW_NUMBER() OVER (
                PARTITION BY sales_order_hk
                ORDER BY load_ts DESC
            ) AS rn
        FROM {{ this }}
        {% if is_incremental() %}
        -- No WHERE needed here; we need latest row per key
        {% endif %}
    ) AS ranked
    WHERE rn = 1
),

new_or_changed AS (
    SELECT
        s.sales_order_hk,
        {{ generate_hash_key(['s.order_date', 's.status'], alias='hash_diff') }},
        s.order_id,
        s.order_date,
        s.status,
        s.load_ts,
        s.record_source
    FROM source_data AS s

    {% if is_incremental() %}
    LEFT JOIN most_recent_satellite m ON s.sales_order_hk = m.sales_order_hk
    WHERE
        -- New sales_order (never seen before)
        m.sales_order_hk IS NULL
        OR
        -- Existing sales_order with changed attributes
        s.hash_diff != m.latest_hash_diff
    {% endif %}
)

SELECT *
FROM new_or_changed
