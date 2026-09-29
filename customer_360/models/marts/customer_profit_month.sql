select
  party_key,
  month as profit_month,
  revenue,
  cost,
  profit
from {{ ref('op_financials', 'customer_profitability') }}
