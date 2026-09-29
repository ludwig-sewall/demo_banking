{{ config(severity='warn') }}

select
  party_key,
  month,
  profit
from {{ ref('customer_profitability') }}
where profit < {{ var('profit_floor_warn') }}
