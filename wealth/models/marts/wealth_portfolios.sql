with open_portfolios as (
  select
    client_id,
    count(*) as portfolio_count,
    sum(market_value) as assets_under_management
  from {{ source('wealth', 'portfolios') }}
  where lower(portfolio_status) = 'open'
  group by 1
)

select
  clients.wealth_customer_id,
  coalesce(open_portfolios.portfolio_count, 0)::integer as portfolio_count,
  coalesce(open_portfolios.assets_under_management, 0)::numeric(18, 2) as assets_under_management
from {{ ref('wealth_customer') }} as clients
left join open_portfolios
  on clients.wealth_customer_id = open_portfolios.client_id
