{{ config(materialized = 'table', schema = 'gold') }}

-- 2016 Census G01 (person characteristics by sex) as Gold reference data, keyed on lga_code.

select * from {{ ref('silver_census_g01') }}