with banking as (
  select
    party_key,
    banking_customer_id
  from {{ ref('demo_banking', 'banking_customer') }}
),

insurance as (
  select
    party_key,
    insurance_customer_id
  from {{ ref('demo_banking_insurance', 'insurance_customer') }}
),

wealth as (
  select
    party_key,
    wealth_customer_id
  from {{ ref('demo_banking_wealth', 'wealth_customer') }}
)

select
  coalesce(banking.party_key, insurance.party_key, wealth.party_key)::varchar as party_key,
  banking.banking_customer_id::varchar as banking_customer_id,
  insurance.insurance_customer_id::varchar as insurance_customer_id,
  wealth.wealth_customer_id::varchar as wealth_customer_id
from banking
full outer join insurance
  on banking.party_key = insurance.party_key
full outer join wealth
  on coalesce(banking.party_key, insurance.party_key) = wealth.party_key
