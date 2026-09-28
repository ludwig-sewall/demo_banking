with profit as (
  select
    party_key,
    sum(profit)::numeric(18, 2) as profit_12m
  from {{ ref('demo_banking_financials', 'customer_profitability') }}
  where {{ trailing_profit_months('month') }}
  group by 1
)

select
  grouped.party_key,
  grouped.banking_customer_id,
  grouped.insurance_customer_id,
  grouped.wealth_customer_id,
  banking.account_count::integer as account_count,
  banking.loan_count::integer as loan_count,
  banking.loan_balance::numeric(18, 2) as loan_balance,
  insurance.active_policy_count::integer as active_policy_count,
  insurance.annual_premium::numeric(18, 2) as annual_premium,
  wealth.portfolio_count::integer as portfolio_count,
  wealth.assets_under_management::numeric(18, 2) as assets_under_management,
  profit.profit_12m::numeric(18, 2) as profit_12m,
  cast('{{ var("demo_as_of_date") }}' as date) as as_of_date
from {{ ref('group_customer') }} as grouped
left join {{ ref('demo_banking', 'banking_products') }} as banking
  on grouped.banking_customer_id = banking.banking_customer_id
left join {{ ref('demo_banking_insurance', 'insurance_policies') }} as insurance
  on grouped.insurance_customer_id = insurance.insurance_customer_id
left join {{ ref('demo_banking_wealth', 'wealth_portfolios') }} as wealth
  on grouped.wealth_customer_id = wealth.wealth_customer_id
left join profit
  on grouped.party_key = profit.party_key
