{# Filter for the current version of each row in a snapshot.
   Matches dbt_valid_to_current set in dbt_project.yml. #}
{% macro snapshot_is_current() %}
    dbt_valid_to = to_date('9999-12-31')
{% endmacro %}
