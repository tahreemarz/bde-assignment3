{{ config(materialized='table', schema='silver') }}

select
    lga_code::int       as lga_code,
    trim(lga_name)      as lga_name
from {{ source('bronze', 'nsw_lga_code') }}