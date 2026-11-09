{{ config(materialized='incremental') }}

/*
    Hub for Sales Order Position Items with Business Key order_id.
*/

{%- set yaml_metadata -%}
hashkey: 'hk_sales_order_position_item_h'
business_keys:
    - order_item_id
additional_columns:
    - message_id
source_models:
    - name: stg_order_items
{%- endset -%}
