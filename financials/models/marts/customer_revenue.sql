-- depends_on: {{ ref('revenue_transactions') }}
select
  party_key::varchar as party_key,
  month::date as month,
  sum(amount)::numeric(18, 2) as revenue
from {{ source('financials', 'revenue_transactions') }}
group by 1, 2
