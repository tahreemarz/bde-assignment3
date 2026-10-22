{{ config(materialized='table', schema='gold') }}

-- Property dimension (SCD2), one row per listing version.
-- listing_neighbourhood matches an LGA name in every monthly file, so the LGA code is
-- attached here; this is what lets Part 4 join listings to the Census tables.

select
    p.dbt_scd_id as property_version_key,
    p.listing_id,
    p.listing_neighbourhood,
    l.lga_code as listing_neighbourhood_lga_code,
    p.property_type,
    p.room_type,
    p.accommodates,
    p.dbt_valid_from,
    p.dbt_valid_to
from {{ ref('property_snapshot') }} as p
left join {{ ref('dim_lga') }} as l
    on upper(trim(p.listing_neighbourhood)) = l.lga_name