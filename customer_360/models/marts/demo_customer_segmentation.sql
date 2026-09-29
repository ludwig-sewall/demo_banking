-- Example segmentation. Copy to <developer>_customer_segmentation_model.sql
-- and tune the case rules (segment + recommended_action).

select
  customer_id,
  case
    when banking_missed_payments >= 2 and banking_payment_remark = 'Yes' then 'payment_distress'
    when insurance_claims > coalesce(insurance_successful_claims, 0) then 'claims_friction'
    when banking_revenue_eur >= 10000 then 'commercial_whale'
    when wealth_revenue_eur >= 3000 and banking_revenue_eur < 500 then 'dormant_wealth'
    when wealth_revenue_eur = 0
      and banking_revenue_eur between 100 and 2000
      and customer_service_notes ilike '%invest%' then 'wealth_opportunity'
    when total_revenue_eur < 200 and banking_missed_payments = 0 then 'onboarding'
    when banking_revenue_eur > 0
      and wealth_revenue_eur > 0
      and insurance_revenue_eur > 0 then 'loyalist'
    when current_interest in ('Mortgage refinancing', 'Credit increase', 'Working capital') then 'credit_intensity'
    when current_interest in ('Business banking', 'Cash management') then 'commercial_expand'
    else 'unclassified'
  end as segment,
  case
    when banking_missed_payments >= 2 and banking_payment_remark = 'Yes' then 'payment_support'
    when insurance_claims > coalesce(insurance_successful_claims, 0) then 'claim_resolution'
    when wealth_revenue_eur = 0
      and banking_revenue_eur between 100 and 2000
      and customer_service_notes ilike '%invest%' then 'wealth_management'
    when banking_revenue_eur >= 10000 then 'business_banking'
    when wealth_revenue_eur >= 3000 and banking_revenue_eur < 500 then 'reactivation'
    else 'retain'
  end as recommended_action,
  cast('{{ var("demo_as_of_date") }}' as date) as as_of_date
from {{ ref('customer_360') }}
