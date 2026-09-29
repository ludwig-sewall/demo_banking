select
  party_key::varchar as party_key,
  month::date as month,
  sum(cost)::numeric(18, 2) as cost
from {{ source('financials', 'allocated_costs') }}
group by 1, 2
