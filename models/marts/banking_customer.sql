select
  banking_customer_id::varchar as banking_customer_id,
  party_key::varchar as party_key,
  case
    when customer_status = 'A' then 'active'
    when customer_status = 'I' then 'inactive'
    when customer_status = 'C' then 'closed'
    when customer_status = 'F' then 'frozen'
    else customer_status
  end::varchar as customer_status
from {{ source('banking', 'customers') }}
