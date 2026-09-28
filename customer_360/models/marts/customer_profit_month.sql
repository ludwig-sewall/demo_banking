select
  party_key,
  month as profit_month,
  revenue,
  cost,
  profit
from {{ ref('demo_banking_financials', 'customer_profitability') }}
