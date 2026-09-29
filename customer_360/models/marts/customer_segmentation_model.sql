-- Optional union starting from demo_customer_segmentation.
-- Exercise 6 builds a separate <developer>_customer_segmentation_model;
-- you can fold it in later with another `union all` branch if you want.

select
  customer_id::varchar as customer_id,
  segment::varchar as segment,
  recommended_action::varchar as recommended_action,
  'demo_customer_segmentation'::varchar as author,
  as_of_date::date as as_of_date
from {{ ref('demo_customer_segmentation') }}

{#
  Optional: after you publish your model, add (outside this Jinja comment):

  union all
  select
    customer_id::varchar as customer_id,
    segment::varchar as segment,
    recommended_action::varchar as recommended_action,
    'yourname_customer_segmentation_model'::varchar as author,
    as_of_date::date as as_of_date
  from {{ ref('yourname_customer_segmentation_model') }}
#}
