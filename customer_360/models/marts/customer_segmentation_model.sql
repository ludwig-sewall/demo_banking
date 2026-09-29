-- Union of published *_customer_segmentation models.
-- Start with the demo model. Workshop participants add another `union all`
-- branch that refs their <name>_customer_segmentation model (see Jinja note below).

select
  customer_id::varchar as customer_id,
  segment::varchar as segment,
  recommended_action::varchar as recommended_action,
  'demo_customer_segmentation'::varchar as author,
  as_of_date::date as as_of_date
from {{ ref('demo_customer_segmentation') }}

{#
  After you publish your own model, add (outside this Jinja comment):

  union all
  select
    customer_id::varchar as customer_id,
    segment::varchar as segment,
    recommended_action::varchar as recommended_action,
    'yourname_customer_segmentation'::varchar as author,
    as_of_date::date as as_of_date
  from {{ ref('yourname_customer_segmentation') }}
#}
