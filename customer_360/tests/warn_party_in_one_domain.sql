{{ config(severity='warn') }}

select
  party_key,
  banking_customer_id,
  insurance_customer_id,
  wealth_customer_id
from {{ ref('group_customer') }}
where (
  case when banking_customer_id is not null then 1 else 0 end
  + case when insurance_customer_id is not null then 1 else 0 end
  + case when wealth_customer_id is not null then 1 else 0 end
) = 1
