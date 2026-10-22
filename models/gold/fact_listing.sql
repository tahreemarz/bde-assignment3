{{ config(materialized = 'table', schema = 'gold') }}

-- Fact table: one row per listing per monthly file.  
-- IDs and metrics only; every descriptive attribute lives in a dimension. 
-- Dimension lookups are resolved at query time with the SCD2 date-range join,
-- so no version keys are stored here.

select
    listing_id,
    host_id,
    file_month,
    price,
    has_availability,
    availability_30,
    number_of_reviews,
    review_scores_rating,
    case when has_availability then 30 - availability_30 end as number_of_stays,
    case when has_availability then (30 - availability_30) * price end as estimated_revenue
from {{ ref('silver_listings') }}