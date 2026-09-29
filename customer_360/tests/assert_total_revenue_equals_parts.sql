-- total_revenue_eur must equal the sum of domain revenues
select
  customer_id,
  banking_revenue_eur,
  wealth_revenue_eur,
  insurance_revenue_eur,
  total_revenue_eur
from {{ ref('customer_360') }}
where total_revenue_eur != (
  banking_revenue_eur + wealth_revenue_eur + insurance_revenue_eur
)
