select
  revenue.party_key,
  revenue.month,
  revenue.revenue::numeric(18, 2) as revenue,
  cost.cost::numeric(18, 2) as cost,
  (revenue.revenue - cost.cost)::numeric(18, 2) as profit
from {{ ref('customer_revenue') }} as revenue
inner join {{ ref('customer_cost') }} as cost
  on revenue.party_key = cost.party_key
 and revenue.month = cost.month
where revenue.revenue is not null
  and cost.cost is not null
