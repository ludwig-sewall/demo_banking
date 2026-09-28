select
  party_key,
  month
from {{ ref('customer_profitability') }}
group by 1, 2
having count(*) > 1
