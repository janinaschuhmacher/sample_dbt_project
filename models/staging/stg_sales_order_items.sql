WITH source_data AS (
    SELECT
        CAST(order_id AS INTEGER) AS order_id,
        CAST(order_position AS INTEGER) AS order_position,
        CAST(product_id AS INTEGER) AS product_id,
        CAST(quantity AS INTEGER) AS quantity,
        CAST(unit_price AS DECIMAL(10, 2)) AS unit_price,
        CAST(line_amount AS DECIMAL(10, 2)) AS line_amount
    FROM {{ ref('orders') }}
),

hashed AS (
    SELECT
        {{ generate_hash_key(['order_id', 'order_position'], alias='sales_order_position_item_hk') }},
        {{ generate_hash_key(['order_id'], alias='sales_order_hk') }},
        order_id,
        order_position,
        product_id,
        quantity,
        unit_price,
        line_amount,
        CURRENT_TIMESTAMP AS load_ts,
        'raw_order_items' AS record_source
    FROM source_data
)

SELECT DISTINCT *
FROM hashed
