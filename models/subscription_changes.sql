{{ config(
    materialized='view'
) }}

select a.subscription_id,	price as new_price,	changed_at, rebilled_at as effective_at
from (
      select *
      from {{ ref('stg_subscription_price_changes') }}
      where change_id in (
                          select max(change_id) as change_id
                          from {{ ref('stg_subscription_price_changes') }}
                          group by subscription_id
                          )
      ) as a
inner join (
            select *
            from {{ ref('stg_rebillings') }}
            where rebilling_id in (
                                    select min(rebilling_id) as rebilling_id
                                    from {{ ref('stg_rebillings') }}
                                    group by subscription_id
                                    )
            ) as b
              on ( a.subscription_id = b.subscription_id)