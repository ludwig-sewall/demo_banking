{# Central anonymization package. Snowflake uses sha2; other adapters fall back to md5. #}

{% macro anonymize(expr) -%}
  {% if target.type == 'snowflake' -%}
    sha2(cast({{ expr }} as varchar))
  {%- else -%}
    md5(cast({{ expr }} as varchar))
  {%- endif %}
{%- endmacro %}
