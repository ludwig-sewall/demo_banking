{{ config(severity='warn') }}

-- Successful claims cannot exceed claims opened
select
  customer_id,
  insurance_claims,
  insurance_successful_claims
from {{ ref('customer_360') }}
where insurance_successful_claims > insurance_claims
