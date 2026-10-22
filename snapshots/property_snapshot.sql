{% snapshot property_snapshot %}

{{
    config(
        schema='silver',
        unique_key='listing_id',
        strategy='timestamp',
        updated_at='file_month'
    )
}}

-- SCD2 snapshot of the PROPERTY entity (decomposed from silver_listings).
-- Exactly one row per listing_id, taken from the most recently loaded month.
-- These attributes genuinely change over the year: Airbnb renamed its property_type
-- taxonomy between the May and July 2020 files (e.g. 'Apartment' became
-- 'Entire apartment' / 'Private room in apartment'), so the datamart must use the
-- version that was valid in each month, not the latest one.

select distinct on (listing_id)
    listing_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    file_month
from {{ ref('silver_listings') }}
where listing_id is not null
order by listing_id, file_month desc

{% endsnapshot %}