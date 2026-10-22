{{ config(materialized = 'view', schema = 'gold') }}

-- Datamart: metrics per host_neighbourhood_lga and month.
-- host_neighbourhood_lga is derived in dim_host from the suburb -> LGA mapping;
-- hosts with a blank or unmatched neighbourhood fall under 'UNKNOWN'.

-- estimated revenue per host = total estimated revenue (active listings) / distinct hosts

with base as (

    select
        f.host_id,
        f.file_month,
        h.host_neighbourhood_lga,
        f.estimated_revenue
    from {{ ref('fact_listing') }} as f
    join {{ ref('dim_host') }} as h
        on  f.host_id = h.host_id
        and f.file_month >= h.dbt_valid_from
        and f.file_month <  coalesce(h.dbt_valid_to, '9999-12-31'::date)

)

select
    host_neighbourhood_lga,
    to_char(file_month, 'MM/YYYY') as month_year,
    count(distinct host_id) as distinct_hosts,
    round(avg(estimated_revenue), 2) as avg_revenue_per_active_listing,
    round(sum(estimated_revenue) / nullif(count(distinct host_id), 0), 2) as revenue_per_host
from base
group by host_neighbourhood_lga, file_month
order by host_neighbourhood_lga, file_month