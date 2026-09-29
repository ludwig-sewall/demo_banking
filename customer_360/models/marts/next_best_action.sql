select
  customer_id,
  case
    when 1 = 0 then 'retain'
    -- when banking_missed_payments >= 2 and banking_payment_remark = 'Yes' then 'payment_support'
    -- when insurance_claims > coalesce(insurance_successful_claims, 0) then 'claim_resolution'
    -- when wealth_revenue_eur = 0 and banking_revenue_eur between 100 and 2000
    --   and customer_service_notes ilike '%invest%' then 'wealth_management'
    -- when banking_revenue_eur >= 10000 then 'business_banking'
    -- when wealth_revenue_eur >= 3000 and banking_revenue_eur < 500 then 'reactivation'
    else 'todo'
  end as recommended_action,
  cast('{{ var("demo_as_of_date") }}' as date) as as_of_date
from {{ ref('customer_360') }}
