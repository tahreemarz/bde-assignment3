{{ config(materialized = 'view', schema = 'gold') }}

-- Datamart: metrics per property_type, room_type, accommodates and month.
-- Same definitions and SCD2 join as dm_listing_neighbourhood. 
-- Because Airbnb renamed its property types between the May and July 2020 files, 
-- categories such as 'Entire apartment' appear from July onwards; 
-- that is the SCD2 history working correctly.

with base as (

    select
        f.listing_id,
        f.host_id,
        f.file_month,
        p.property_type,
        p.room_type,
        p.accommodates,
        f.price,
        f.has_availability,
        f.review_scores_rating,
        f.number_of_stays,
        f.estimated_revenue,
        h.host_is_superhost
    from {{ ref('fact_listing') }} as f
    join {{ ref('dim_property') }} as p
        on  f.listing_id = p.listing_id
        and f.file_month >= p.dbt_valid_from
        and f.file_month <  coalesce(p.dbt_valid_to, '9999-12-31'::date)
    join {{ ref('dim_host') }} as h
        on  f.host_id = h.host_id
        and f.file_month >= h.dbt_valid_from
        and f.file_month <  coalesce(h.dbt_valid_to, '9999-12-31'::date)

),

monthly as (

    select
        property_type,
        room_type,
        accommodates,
        file_month,
        count(*) as total_listings,
        count(*) filter (where has_availability) as active_listings,
        count(*) filter (where not has_availability) as inactive_listings,
        min(price) filter (where has_availability) as min_price,
        max(price) filter (where has_availability) as max_price,
        percentile_cont(0.5) within group (order by price)
            filter (where has_availability) as median_price,
        avg(price) filter (where has_availability) as avg_price,
        count(distinct host_id) as distinct_hosts,
        count(distinct host_id) filter (where host_is_superhost) as superhosts,
        avg(review_scores_rating) filter (where has_availability) as avg_review_scores_rating,
        sum(number_of_stays) as total_stays,
        avg(estimated_revenue) as avg_revenue_per_active_listing
    from base
    group by property_type, room_type, accommodates, file_month
)

select
    property_type,
    room_type,
    accommodates,
    to_char(file_month, 'MM/YYYY') as month_year,
    round(active_listings * 100.0 / nullif(total_listings, 0), 2) as active_listing_rate,
    min_price,
    max_price,
    round(median_price::numeric, 2) as median_price,
    round(avg_price, 2) as avg_price,
    distinct_hosts,
    round(superhosts * 100.0 / nullif(distinct_hosts, 0), 2) as superhost_rate,
    round(avg_review_scores_rating, 2) as avg_review_scores_rating,
    round((active_listings - lag(active_listings) over w) * 100.0
          / nullif(lag(active_listings) over w, 0), 2) as pct_change_active_listings,
    round((inactive_listings - lag(inactive_listings) over w) * 100.0
          / nullif(lag(inactive_listings) over w, 0), 2) as pct_change_inactive_listings,
    total_stays,
    round(avg_revenue_per_active_listing, 2) as avg_revenue_per_active_listing
from monthly
window w as (partition by property_type, room_type, accommodates order by file_month)
order by property_type, room_type, accommodates, file_month