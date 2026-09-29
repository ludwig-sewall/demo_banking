with banking as (
  select
    party_key,
    banking_customer_id
  from {{ ref('op_banking', 'banking_customer') }}
),

insurance as (
  select
    party_key,
    insurance_customer_id
  from {{ ref('op_insurance', 'insurance_customer') }}
),

wealth as (
  select
    party_key,
    wealth_customer_id
  from {{ ref('op_wealth', 'wealth_customer') }}
),

grouped as (
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
),

profit as (
  select
    party_key,
    sum(profit)::numeric(18, 2) as profit_12m
  from {{ ref('op_financials', 'customer_profitability') }}
  where {{ trailing_profit_months('month') }}
  group by 1
)

select
  grouped.party_key,
  grouped.banking_customer_id,
  grouped.insurance_customer_id,
  grouped.wealth_customer_id,
  profile.segment::varchar as segment,
  profile.region::varchar as region,
  profile.channel::varchar as channel,
  profile.lifecycle::varchar as lifecycle,
  profile.value_tier::varchar as value_tier,
  banking.account_count::integer as account_count,
  banking.loan_count::integer as loan_count,
  banking.loan_balance::numeric(18, 2) as loan_balance,
  insurance.active_policy_count::integer as active_policy_count,
  insurance.annual_premium::numeric(18, 2) as annual_premium,
  wealth.portfolio_count::integer as portfolio_count,
  wealth.assets_under_management::numeric(18, 2) as assets_under_management,
  profit.profit_12m::numeric(18, 2) as profit_12m,
  cast('{{ var("demo_as_of_date") }}' as date) as as_of_date
from grouped
inner join {{ ref('party_profile') }} as profile
  on grouped.party_key = profile.party_key
left join {{ ref('op_banking', 'banking_products') }} as banking
  on grouped.banking_customer_id = banking.banking_customer_id
left join {{ ref('op_insurance', 'insurance_policies') }} as insurance
  on grouped.insurance_customer_id = insurance.insurance_customer_id
left join {{ ref('op_wealth', 'wealth_portfolios') }} as wealth
  on grouped.wealth_customer_id = wealth.wealth_customer_id
left join profit
  on grouped.party_key = profit.party_key
