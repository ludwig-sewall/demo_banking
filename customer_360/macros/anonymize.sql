{# Re-export so models can call {{ anonymize('column') }} without the package namespace. #}
{% macro anonymize(expr) %}
  {{ return(anonymize_utils.anonymize(expr)) }}
{% endmacro %}
