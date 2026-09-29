{{ config(severity='warn') }}

-- Payment remark should accompany missed payments (and vice versa for severe cases)
select
  customer_id,
  banking_missed_payments,
  banking_payment_remark
from {{ ref('customer_360') }}
where (banking_missed_payments >= 2 and banking_payment_remark != 'Yes')
   or (banking_missed_payments = 0 and banking_payment_remark = 'Yes')
