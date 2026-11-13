-- models/raw_vault/hubs/hub_sales_orders.sql
{{
    config(
        materialized='incremental',
        unique_key='sales_order_position_item_hk',
        on_schema_change='append_new_columns',
        cluster_by=['sales_order_position_item_hk'],
        tags=['raw_vault', 'hub']
    )
}}

WITH source_data AS (
    SELECT
        sales_order_position_item_hk,
        order_id,
        order_position,
        load_ts,
        record_source
    FROM {{ ref('stg_sales_order_items') }}
),

-- In an incremental run, only consider new business keys
deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY sales_order_position_item_hk
            ORDER BY load_ts ASC
        ) AS row_num
    FROM source_data

    {% if is_incremental() %}
    WHERE sales_order_position_item_hk NOT IN (
        SELECT sales_order_position_item_hk FROM {{ this }}
    )
    {% endif %}
)

SELECT
    sales_order_position_item_hk,
    order_id,
    order_position,
    load_ts,
    record_source
FROM deduped
WHERE row_num = 1