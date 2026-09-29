{# Union every published <name>_customer_segmentation model in this project. #}
{% set segment_models = [] %}
{% for node in graph.nodes.values() %}
  {% if node.resource_type == 'model'
      and node.name.endswith('_customer_segmentation')
      and node.package_name == project_name %}
    {% do segment_models.append(node.name) %}
  {% endif %}
{% endfor %}
{% set segment_models = segment_models | sort %}

{% if segment_models | length == 0 %}
select
  cast(null as varchar) as customer_id,
  cast(null as varchar) as segment,
  cast(null as varchar) as author,
  cast(null as date) as as_of_date
where 1 = 0
{% else %}
  {% for model_name in segment_models %}
select
  customer_id::varchar as customer_id,
  segment::varchar as segment,
  '{{ model_name }}'::varchar as author,
  as_of_date::date as as_of_date
from {{ ref(model_name) }}
    {% if not loop.last %}
union all
    {% endif %}
  {% endfor %}
{% endif %}
