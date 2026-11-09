{{ config(materialized='incremental') }}

/*
    Hub for Orders with Business Key order_id.
*/

{%- set yaml_metadata -%}
hashkey: 'hk_sales_order_h'
business_keys:
    - order_id
additional_columns:
    - message_id
source_models:
    - name: stg_orders
{%- endset -%}
