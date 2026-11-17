{% macro grant_select(schema = target.schema,role = target.role,database = target.database ) %}

    {% set sql %}
        use database {{ database }};
        grant usage on schema {{ schema }} to role {{ role }};
        grant select on all tables in {{ schema }} to role {{ role }};
        grant select on all views in schema {{ schema }} to  {{ role }};
    {% endset%}
    {{ log('Granting select on schema' ~ schema ~ 'to role' ~ role) }}
    {% do run_query(sql) %}
{% endmacro %}