{{ config(severity='warn') }}

select
  party_key,
  month,
  revenue
from {{ ref('customer_revenue') }}
where revenue is null
   or revenue > {{ var('revenue_outlier_warn') }}
