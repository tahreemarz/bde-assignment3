{{ config(materialized='table', schema='gold') }}

-- Static LGA dimension (reference data, no SCD needed).

select
    cast(lga_code as integer) as lga_code,
    upper(trim(lga_name)) as lga_name
from {{ ref('silver_nsw_lga_code') }}
where lga_code is not null