select
  insurance_customer_id::varchar as insurance_customer_id,
  party_key::varchar as party_key,
  lower(customer_status)::varchar as customer_status
from {{ source('insurance', 'customers') }}
