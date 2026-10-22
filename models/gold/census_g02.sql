{{ config(materialized = 'table', schema = 'gold') }}

-- 2016 Census G02 (medians and averages) as Gold reference data, keyed on lga_code.

select * from {{ ref('silver_census_g02') }}