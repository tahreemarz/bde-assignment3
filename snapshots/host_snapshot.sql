{% snapshot host_snapshot %}

{{
    config(
        schema = 'silver',
        unique_key = 'host_id',
        strategy = 'timestamp',
        updated_at = 'file_month'
    )
}}

-- SCD2 snapshot of the HOST entity (decomposed from silver_listings).
-- Exactly one row per host_id, taken from the most recently loaded month.
-- dbt opens a new version whenever file_month is newer than the stored one.
-- The host_neighbourhood -> LGA lookup is done in gold.dim_host (static mapping).

select distinct on (host_id)
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    file_month
from {{ ref('silver_listings') }}
where host_id is not null
  -- dbt snapshot --vars '{"snapshot_as_of": "2020-09-01"}' makes this run see only months up to that date,
  -- so history can be rebuilt month by month if a run was missed.
  -- With no var passed (normal job runs) the default lets every loaded month through.
  and file_month <= '{{ var("snapshot_as_of", "9999-12-31") }}'::date
order by host_id, file_month desc

{% endsnapshot %}