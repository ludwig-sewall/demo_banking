with expected as (
  select
    party_key,
    sum(profit) as profit_12m
  from {{ ref('demo_banking_financials', 'customer_profitability') }}
  where {{ trailing_profit_months('month') }}
  group by 1
)

select
  actual.party_key,
  actual.profit_12m as published_profit_12m,
  expected.profit_12m as source_profit_12m
from {{ ref('customer_360') }} as actual
full outer join expected
  on actual.party_key = expected.party_key
where coalesce(actual.profit_12m, 0) != coalesce(expected.profit_12m, 0)
   or actual.party_key is null
