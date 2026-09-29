{% macro trailing_profit_months(month_sql) %}
{{ month_sql }} > '{{ var("demo_as_of_date") }}'::date - interval '12 months'
and {{ month_sql }} <= '{{ var("demo_as_of_date") }}'::date
{% endmacro %}
