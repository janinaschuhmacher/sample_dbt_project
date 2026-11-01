select
    cast(order_id as integer) as order_id,
    cast(customer_id as integer) as customer_id,
    cast(order_date as date) as order_date,
    cast(amount as decimal(10,2)) as amount
from {{ ref('orders') }}