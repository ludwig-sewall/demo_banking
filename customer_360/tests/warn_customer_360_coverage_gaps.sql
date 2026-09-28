{{ config(severity='warn') }}

select
  party_key,
  banking_customer_id,
  insurance_customer_id,
  wealth_customer_id,
  profit_12m
from {{ ref('customer_360') }}
where profit_12m is null
   or (banking_customer_id is not null and account_count is null)
   or (insurance_customer_id is not null and active_policy_count is null)
   or (wealth_customer_id is not null and portfolio_count is null)
   or (
     case when banking_customer_id is not null then 1 else 0 end
     + case when insurance_customer_id is not null then 1 else 0 end
     + case when wealth_customer_id is not null then 1 else 0 end
   ) < 2
