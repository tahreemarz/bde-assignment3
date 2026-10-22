{{ config(materialized = 'table', schema = 'silver') }}

select
    listing_id::bigint as listing_id,
    host_id::bigint as host_id,
    nullif(trim(host_name), '') as host_name,
    to_date(nullif(trim(host_since), ''), 'DD/MM/YYYY') as host_since,
    case lower(trim(host_is_superhost)) when 't' then true when 'f' then false end as host_is_superhost,
    upper(nullif(trim(host_neighbourhood), '')) as host_neighbourhood,
    trim(listing_neighbourhood) as listing_neighbourhood,
    trim(property_type) as property_type,
    trim(room_type) as room_type,
    nullif(trim(accommodates), '')::int as accommodates,
    nullif(regexp_replace(price, '[^0-9.]', '', 'g'), '')::numeric(10,2) as price,
    (lower(trim(has_availability)) = 't') as has_availability,
    nullif(trim(availability_30), '')::int as availability_30,
    nullif(trim(number_of_reviews), '')::int as number_of_reviews,
    nullif(nullif(trim(review_scores_rating), ''), 'NaN')::numeric as review_scores_rating,
    to_date(nullif(trim(scraped_date), ''), 'YYYY-MM-DD') as scraped_date,
    to_date(file_month || '-01', 'YYYY-MM-DD') as file_month
from {{ source('bronze', 'listings') }}