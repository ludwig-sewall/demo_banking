{{ config(severity='warn') }}

select
  banking_customer_id,
  account_count,
  loan_count,
  loan_balance
from {{ ref('banking_products') }}
where account_count < 0
   or loan_count < 0
   or loan_balance < 0
