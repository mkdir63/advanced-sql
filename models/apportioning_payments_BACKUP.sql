{{ config(materialized='view') }}

-- extract unique values for 'task_id'
{%- set tasks = dbt_utils.get_column_values(table=ref('stg_payments'), column='task_id') | sort %}
{%- set appended_data = [] %} -- help table for creating final table from concating all created tables
{%- set task = 5 %}


with data_p as (

    select *
    from {{ ref('stg_payments') }}

), -- basis of following operations


table_t_{{task}} as (

    select *
    from data_p
    where task_id = {{task}}

),      -- table of a single task

table_s_{{task}} as (

    select payment_id, task_id, amount as inbound_amount
    from table_t_{{task}}
    where payment_type = 'inbound'

)      -- table of only IN payments for single task

{%- set payout_query %}
    select amount
    from {{ ref('stg_payments') }}
    where task_id = {{task}} and payment_type = 'payout'
{%- endset %}
{%- set payout_list = run_query(payout_query) %}    -- get payout value for single task
{%- if payout_list|length == 0 %} {%- set payout = 0 %} -- integrity check: len() applied to a table returns # rows
{%- else %} {%- set payout = payout_list.columns[0].values() %}
{%- endif %}
{%- set payout_amount = [] %} -- payout amount column, to append to table at the end

-- run over the rows of table_s_




select * from data_p
