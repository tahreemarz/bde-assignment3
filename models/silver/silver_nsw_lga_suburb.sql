{{ config(materialized='table', schema='silver') }}

select
    upper(trim(lga_name))     as lga_name,
    upper(trim(suburb_name))  as suburb_name
from {{ source('bronze', 'nsw_lga_suburb') }}
where suburb_name is not null