{{ config(severity='warn') }}

select
  party_key,
  month,
  cost
from {{ ref('customer_cost') }}
where cost is null
