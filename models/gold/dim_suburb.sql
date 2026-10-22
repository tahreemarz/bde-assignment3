{{ config(materialized='table', schema='gold') }}

-- Static suburb dimension (reference data, no SCD needed). 
-- Each suburb maps to exactly one LGA in the source file; lga_code comes from dim_lga.

select
    s.suburb_name,
    s.lga_name,
    l.lga_code
from {{ ref('silver_nsw_lga_suburb') }} as s
left join {{ ref('dim_lga') }} as l
    on s.lga_name = l.lga_name