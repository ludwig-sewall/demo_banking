select
  banking_customer_id::varchar as banking_customer_id,
  party_key::varchar as party_key,
  lower(customer_status)::varchar as customer_status,
  'hello world' as message
from {{ source('banking', 'customers') }}
