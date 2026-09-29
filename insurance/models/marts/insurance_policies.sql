with active_policies as (
  select
    insurance_customer_id,
    count(*) as active_policy_count,
    sum(annual_premium) as annual_premium
  from {{ source('insurance', 'policies') }}
  where lower(policy_status) = 'active'
  group by 1
)

select
  customers.insurance_customer_id,
  coalesce(active_policies.active_policy_count, 0)::integer as active_policy_count,
  coalesce(active_policies.annual_premium, 0)::numeric(18, 2) as annual_premium
from {{ ref('insurance_customer') }} as customers
left join active_policies
  on customers.insurance_customer_id = active_policies.insurance_customer_id
