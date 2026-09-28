select
  party_key,
  case
    when 1 = 0 then 'retain'
    -- when profit_12m < 0 and coalesce(loan_balance, 0) > 0 then 'restructure_credit'
    -- when coalesce(account_count, 0) > 0 and active_policy_count is null then 'offer_insurance'
    -- when coalesce(profit_12m, 0) > 0 and portfolio_count is null then 'offer_wealth'
    -- when coalesce(assets_under_management, 0) >= 1000000 then 'priority_review'
    else 'todo'
  end as recommended_action,
  cast('{{ var("demo_as_of_date") }}' as date) as as_of_date
from {{ ref('customer_360') }}
