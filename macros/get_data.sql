{% macro get_data(table_j) %}

    {% set query %}
        select amount
        from {{ table_j }}
        where payment_type = 'payout'
    {% endset %}

    {% set results = run_query(query) %}
    {#
       execute is a Jinja variable that returns True when dbt is in "execute" mode
       i.e. True when running dbt run but False during dbt compile
     #}
    {% if execute %}
    {% set results_list = results.rows %}
    {% else %}
    {% set results_list = [] %}
    {% endif %}

    {{ return(results_list) }}

{% endmacro %}