select
  party_key,
  month,
  revenue,
  cost,
  profit
from {{ ref('customer_profitability') }}
where profit != revenue - cost
   or profit is null
   or revenue is null
   or cost is null
