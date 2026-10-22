{{ config(materialized='table', schema='gold') }}

-- Host dimension (SCD2). Every version of a host is kept; 
-- dbt_valid_from/dbt_valid_to define when each version was current. Join from the fact table with:
-- f.file_month >= d.dbt_valid_from and f.file_month < coalesce(d.dbt_valid_to, '9999-12-31')
--
-- host_neighbourhood is mapped to an LGA through dim_suburb. 
-- Blank neighbourhoods (about a third of listings) and 
-- values with no suburb match (e.g. 'OVERSEAS') are assigned the LGA 'UNKNOWN'.

select
    h.dbt_scd_id as host_version_key,
    h.host_id,
    h.host_name,
    h.host_since,
    h.host_is_superhost,
    h.host_neighbourhood,
    coalesce(s.lga_name, 'UNKNOWN') as host_neighbourhood_lga,
    s.lga_code as host_neighbourhood_lga_code,
    h.dbt_valid_from,
    h.dbt_valid_to
from {{ ref('host_snapshot') }} as h
left join {{ ref('dim_suburb') }} as s
    on h.host_neighbourhood = s.suburb_name