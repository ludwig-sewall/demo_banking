with banking as (
  select
    c.party_key,
    c.banking_customer_id,
    c.customer_status as banking_status,
    coalesce(p.account_count, 0) as account_count,
    coalesce(p.loan_count, 0) as loan_count,
    coalesce(p.loan_balance, 0)::numeric(18, 2) as loan_balance
  from {{ ref('banking_customer') }} as c
  left join {{ ref('banking_products') }} as p
    on c.banking_customer_id = p.banking_customer_id
),

insurance as (
  select
    c.party_key,
    c.insurance_customer_id,
    c.customer_status as insurance_status,
    coalesce(p.active_policy_count, 0) as active_policy_count,
    coalesce(p.annual_premium, 0)::numeric(18, 2) as annual_premium
  from {{ ref('insurance_customer') }} as c
  left join {{ ref('insurance_policies') }} as p
    on c.insurance_customer_id = p.insurance_customer_id
),

wealth as (
  select
    c.party_key,
    c.wealth_customer_id,
    c.client_status as wealth_status,
    coalesce(p.portfolio_count, 0) as portfolio_count,
    coalesce(p.assets_under_management, 0)::numeric(18, 2) as assets_under_management
  from {{ ref('wealth_customer') }} as c
  left join {{ ref('wealth_portfolios') }} as p
    on c.wealth_customer_id = p.wealth_customer_id
),

financials as (
  select
    party_key,
    sum(revenue)::numeric(18, 2) as total_revenue,
    sum(cost)::numeric(18, 2) as total_cost,
    sum(profit)::numeric(18, 2) as total_profit,
    count(*)::integer as profit_months
  from {{ ref('customer_profitability') }}
  group by 1
),

parties as (
  select party_key from banking
  union
  select party_key from insurance
  union
  select party_key from wealth
  union
  select party_key from financials
)

select
  parties.party_key::varchar as customer_id,
  md5(parties.party_key)::varchar as customer_id_hash,

  banking.banking_customer_id::varchar as banking_customer_id,
  banking.banking_status::varchar as banking_status,
  coalesce(banking.account_count, 0)::integer as account_count,
  coalesce(banking.loan_count, 0)::integer as loan_count,
  coalesce(banking.loan_balance, 0)::numeric(18, 2) as loan_balance,

  insurance.insurance_customer_id::varchar as insurance_customer_id,
  insurance.insurance_status::varchar as insurance_status,
  coalesce(insurance.active_policy_count, 0)::integer as active_policy_count,
  coalesce(insurance.annual_premium, 0)::numeric(18, 2) as annual_premium,

  wealth.wealth_customer_id::varchar as wealth_customer_id,
  wealth.wealth_status::varchar as wealth_status,
  coalesce(wealth.portfolio_count, 0)::integer as portfolio_count,
  coalesce(wealth.assets_under_management, 0)::numeric(18, 2) as assets_under_management,

  coalesce(financials.total_revenue, 0)::numeric(18, 2) as total_revenue,
  coalesce(financials.total_cost, 0)::numeric(18, 2) as total_cost,
  coalesce(financials.total_profit, 0)::numeric(18, 2) as total_profit,
  coalesce(financials.profit_months, 0)::integer as profit_months,

  (
    case when banking.party_key is not null then 1 else 0 end
    + case when insurance.party_key is not null then 1 else 0 end
    + case when wealth.party_key is not null then 1 else 0 end
  )::integer as domain_count,

  cast('2026-03-31' as date) as as_of_date
from parties
left join banking
  on parties.party_key = banking.party_key
left join insurance
  on parties.party_key = insurance.party_key
left join wealth
  on parties.party_key = wealth.party_key
left join financials
  on parties.party_key = financials.party_key
