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

)      -- table of a single task

 -- table of only IN payments for single task

{%- set table_s_query %}
    select *
    from {{ ref('stg_payments') }}
    where task_id = {{task}} and payment_type = 'inbound'
{%- endset %}
{%- set table_s_at = run_query(table_s_query) %}

{%- if execute %}
    {%- set table_s = table_s_at.columns[3].values() %}
    {%- else %}
    {%- set table_s = [] %}
{%- endif %}

-- FIRST: check payout

{%- set payout_query %}
    select *
    from {{ ref('stg_payments') }}
    where task_id = {{task}} and payment_type = 'payout'
{%- endset %}
{%- set payout_at = run_query(payout_query) %}

{% if execute %}
    {%- set payout_tt = payout_at.columns[3].values() %}
{%- else %}
    {%- set payout_tt = [] %}
{%- endif %}

{%- if payout_tt|length == 0 %}
    {%- set payout_amount = 0 %} -- integrity check: len() applied to a table returns # rows
{%- else %}
    {%- set payout_amount = [payout_tt[0]] %}  -- OUT records
{%- endif %}

{%- set payout_list = [] %} -- payout amount column, to append to table at the end
{%- set temp = 0 %}


-- run all over table_s

{%- for item in table_s %}

    {%- set payout = payout_amount|last %}
    {{ log("Payout: " ~ payout, info=True) }}

    {%- if payout == 0 %}
        {%- do payout_list.append(payout) %}
    {%- else %}
        {%- set temp = payout - item %}
        {%- if temp>0 %}
            {%- do payout_list.append(item) %}
            {%- do payout_amount.append(temp) %}
        {%- else %}
            {%- do payout_list.append(payout) %}
            {%- do payout_amount.append(0) %}
        {%- endif %}
    {%- endif %}

{%- endfor %}

{{ log("Payout_list: " ~ payout_list, info=True) }}

select * from data_p
