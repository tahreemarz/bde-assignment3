{{ config(materialized='table', schema='silver') }}

select
    cast(replace(lga_code_2016, 'LGA', '') as integer) as lga_code,
    cast(nullif(median_age_persons, '') as integer) as median_age_persons,
    cast(nullif(median_mortgage_repay_monthly, '') as integer) as median_mortgage_repay_monthly,
    cast(nullif(median_tot_prsnl_inc_weekly, '') as integer) as median_tot_prsnl_inc_weekly,
    cast(nullif(median_rent_weekly, '') as integer) as median_rent_weekly,
    cast(nullif(median_tot_fam_inc_weekly, '') as integer) as median_tot_fam_inc_weekly,
    cast(nullif(average_num_psns_per_bedroom, '') as numeric(6,2)) as average_num_psns_per_bedroom,
    cast(nullif(median_tot_hhd_inc_weekly, '') as integer) as median_tot_hhd_inc_weekly,
    cast(nullif(average_household_size, '') as numeric(6,2)) as average_household_size
from {{ source('bronze', 'census_g02') }}
where lga_code_2016 is not null