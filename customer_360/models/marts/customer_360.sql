with book as (
  select * from {{ ref('customer_book') }}
)

select
  book.customer_id::varchar as customer_id,
  {{ anonymize('book.customer_id') }}::varchar as customer_id_hash,
  book.banking_revenue_eur::numeric(18, 2) as banking_revenue_eur,
  book.wealth_revenue_eur::numeric(18, 2) as wealth_revenue_eur,
  book.insurance_revenue_eur::numeric(18, 2) as insurance_revenue_eur,
  (
    book.banking_revenue_eur
    + book.wealth_revenue_eur
    + book.insurance_revenue_eur
  )::numeric(18, 2) as total_revenue_eur,
  round(
    (
      book.banking_revenue_eur
      + book.wealth_revenue_eur
      + book.insurance_revenue_eur
    ) / 12.0,
    2
  )::numeric(18, 2) as monthly_avg_revenue_eur,
  book.banking_missed_payments::integer as banking_missed_payments,
  book.banking_payment_remark::varchar as banking_payment_remark,
  book.insurance_claims::integer as insurance_claims,
  book.insurance_successful_claims::integer as insurance_successful_claims,
  book.customer_service_notes::varchar as customer_service_notes,
  book.current_interest::varchar as current_interest,
  cast('{{ var("demo_as_of_date") }}' as date) as as_of_date
from book
