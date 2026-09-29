select
  banking_customer_id::varchar as banking_customer_id,
  party_key::varchar as party_key,
  lower(customer_status)::varchar as customer_status,
  'Hello' as message
  
from {{ source('banking', 'customers') }}
