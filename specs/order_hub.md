# Order Hub

## Purpose
Represent each distinct order identified by its business key.

## Grain
One row per distinct order business key.

## Source
`stg_sales_orders`

## Business key
`order_id`

## Hub contents
- Deterministic hub key: `hk_order_h`
- Business key: `order_id`
- Load timestamp and record source, following the project's Data Vault convention

Do not put changing order attributes such as amount or status in the hub.

## Acceptance
- Every source order has a non-null `order_id`.
- The hub contains one row per distinct `order_id`.
- The same `order_id` produces the same hub key on repeated runs.