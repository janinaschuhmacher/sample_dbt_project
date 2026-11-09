{{ config(materialized='incremental') }}

/*
    Hub for Customers with Business Key order_id.
*/

{%- set yaml_metadata -%}
hashkey: 'hk_customer_h'
business_keys:
    - customer_id
additional_columns:
    - message_id
source_models:
    - name: stg_customers
{%- endset -%}
