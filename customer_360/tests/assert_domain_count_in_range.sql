select
  customer_id,
  domain_count
from {{ ref('customer_360') }}
where domain_count < 0
   or domain_count > 3
