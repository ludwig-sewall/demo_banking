{# Demo stand-in for a central encryption / anonymization package.
   Uses Snowflake sha2 so values are irreversible in the warehouse. #}

{% macro anonymize(expr) -%}
  sha2(cast({{ expr }} as varchar))
{%- endmacro %}
