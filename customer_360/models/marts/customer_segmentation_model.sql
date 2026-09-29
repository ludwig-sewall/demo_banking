-- Union of published *_customer_segmentation models.
-- Start with the demo model. Workshop participants add another `union all`
-- branch that refs their <name>_customer_segmentation model.

select
  customer_id::varchar as customer_id,
  segment::varchar as segment,
  recommended_action::varchar as recommended_action,
  'demo_customer_segmentation'::varchar as author,
  as_of_date::date as as_of_date
from {{ ref('demo_customer_segmentation') }}

-- Example after you publish your own model:
-- union all
-- select
--   customer_id::varchar as customer_id,
--   segment::varchar as segment,
--   recommended_action::varchar as recommended_action,
--   'yourname_customer_segmentation'::varchar as author,
--   as_of_date::date as as_of_date
-- from {{ ref('yourname_customer_segmentation') }}
