{{ 
    config(
        materialized='incremental',
        unique_key=['customer_hk', 'load_ts'],
        on_schema_change='append_new_columns',
        cluster_by=['customer_hk', 'load_ts'],
        tags=['raw_vault', 'satellite']
    ) 
}}

WITH source_data AS (
    SELECT *
    FROM {{ ref('stg_customers') }}
),
most_recent_satellite AS (
    SELECT
        customer_hk,
        hash_diff AS latest_hash_diff,
        load_ts AS latest_load_ts
    FROM (
        SELECT
            customer_hk,
            hash_diff,
            load_ts,
            ROW_NUMBER() OVER (
                PARTITION BY customer_hk
                ORDER BY load_ts DESC
            ) AS rn
        FROM {{ this }}
        {% if is_incremental() %}
        -- No WHERE needed here; we need latest row per key
        {% endif %}
    ) ranked
    WHERE rn = 1
),
new_or_changed AS (
    SELECT
        s.customer_hk,
        {{ generate_hash_key(['s.signup_date', 's.country'], alias='hash_diff') }},
        s.signup_date,
        s.country,
        s.load_ts,
        s.record_source
    FROM source_data s

    {% if is_incremental() %}
    LEFT JOIN most_recent_satellite m ON s.customer_hk = m.customer_hk
    WHERE
        -- New customer (never seen before)
        m.customer_hk IS NULL
        OR
        -- Existing customer with changed attributes
        s.hash_diff != m.latest_hash_diff
    {% endif %}
)

SELECT *
FROM new_or_changed
