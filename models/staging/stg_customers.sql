select
    cast(customer_id as integer) as customer_id,
    cast(signup_date as date) as signup_date,
    upper(country) as country
from {{ ref('customers') }}