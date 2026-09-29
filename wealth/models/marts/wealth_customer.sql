select
  client_id::varchar as wealth_customer_id,
  party_key::varchar as party_key,
  lower(client_status)::varchar as client_status
from {{ source('wealth', 'clients') }}
