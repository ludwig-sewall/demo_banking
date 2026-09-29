-- Thin cross-project anchors so Account Lineage includes every mesh domain.
select
  'banking'::varchar as domain,
  count(*)::integer as customers
from {{ ref('op_banking', 'banking_customer') }}

union all

select
  'insurance'::varchar as domain,
  count(*)::integer as customers
from {{ ref('op_insurance', 'insurance_customer') }}

union all

select
  'wealth'::varchar as domain,
  count(*)::integer as customers
from {{ ref('op_wealth', 'wealth_customer') }}

union all

select
  'financials'::varchar as domain,
  count(*)::integer as customers
from {{ ref('op_financials', 'customer_profitability') }}
