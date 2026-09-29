{{ config(severity='warn') }}

select
  wealth_customer_id,
  portfolio_count,
  assets_under_management
from {{ ref('wealth_portfolios') }}
where portfolio_count < 0
   or assets_under_management < 0
