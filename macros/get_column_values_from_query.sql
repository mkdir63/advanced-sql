-- macros/get_column_values_from_query.sql
{% macro get_column_values_from_query(query, column) -%}

-- Prevent querying of db in parsing mode. This works because this macro does not create any new refs.
    {%- if not execute -%}
        {{ return('') }}
    {% endif %}

    {% set column_values_sql %}
    with cte as (
        {{ query }}
    )
    select
        {{ column }} as value

    from cte
    group by 1
    order by count(*) desc

    {% endset %}

    {%- set results = run_query(column_values_sql) %}
    {{ log(results, info=True) }}
    {% set results_list = results.columns[0].values() %}

    {{ log(results_list, info=True) }}
    {{ return(results_list) }}

{%- endmacro %}
