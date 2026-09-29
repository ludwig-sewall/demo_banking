select
  insurance_customer_id,
  active_policy_count,
  annual_premium
from {{ ref('insurance_policies') }}
where active_policy_count < 0
   or annual_premium < 0
