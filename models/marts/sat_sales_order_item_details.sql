{{ 
    config(
        materialized='incremental',
        unique_key=['sales_order_position_item_hk', 'load_ts'],
        on_schema_change='append_new_columns',
        cluster_by=['sales_order_position_item_hk', 'load_ts'],
        tags=['raw_vault', 'satellite']
    ) 
}}

WITH source_data AS (
    SELECT *
    FROM {{ ref('stg_sales_order_items') }}
),

-- Get the most recent hash_diff for each sales_order_position_item_hk already in the Satellite
most_recent_satellite AS (
    SELECT
        sales_order_position_item_hk,
        hash_diff AS latest_hash_diff,
        load_ts AS latest_load_ts
    FROM (
        SELECT
            sales_order_position_item_hk,
            hash_diff,
            load_ts,
            ROW_NUMBER() OVER (
                PARTITION BY sales_order_position_item_hk
                ORDER BY load_ts DESC
            ) AS rn
        FROM {{ this }}
        {% if is_incremental() %}
        -- No WHERE needed here; we need latest row per key
        {% endif %}
    ) ranked
    WHERE rn = 1
),

-- Only insert rows where the hash_diff has changed
new_or_changed AS (
    SELECT
        s.sales_order_position_item_hk,
        {{ generate_hash_key(['s.product_id', 's.quantity', 's.unit_price', 's.line_amount'], alias='hash_diff') }},
        s.order_id,
        s.order_position,
        s.product_id,
        s.quantity,
        s.unit_price,
        s.line_amount,
        s.load_ts,
        s.record_source
    FROM source_data s

    {% if is_incremental() %}
    LEFT JOIN most_recent_satellite m ON s.sales_order_position_item_hk = m.sales_order_position_item_hk
    WHERE
        -- New sales_order_position_item (never seen before)
        m.sales_order_position_item_hk IS NULL
        OR
        -- Existing sales_order_position_item with changed attributes
        s.hash_diff != m.latest_hash_diff
    {% endif %}
)

SELECT * FROM new_or_changed
