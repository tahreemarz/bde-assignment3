# bde-assignment3 – dbt project

dbt Cloud project for **94693 Big Data Engineering, Assignment 3** (UTS, Spring 2026).
It transforms Airbnb listing data for Sydney (May 2020 – April 2021) and 2016 Census
reference data, loaded into PostgreSQL by an Airflow DAG, into a medallion data
warehouse (Bronze → Silver → Gold) with a star schema and three datamart views.

## Layers

| Layer | Location | Contents |
|---|---|---|
| Bronze | `models/silver/sources.yml` | Five raw tables loaded by Airflow (`listings`, `census_g01`, `census_g02`, `nsw_lga_code`, `nsw_lga_suburb`), all columns `TEXT` |
| Silver | `models/silver/` | Cleaned, typed versions of the Bronze tables (`silver_*`) |
| Silver (SCD2) | `snapshots/` | `host_snapshot` and `property_snapshot`, timestamp strategy on `file_month` |
| Gold | `models/gold/` | `dim_host`, `dim_property` (SCD2), `dim_lga`, `dim_suburb`, `census_g01`, `census_g02`, `fact_listing` |
| Datamart | `models/gold/datamart/` | `dm_listing_neighbourhood`, `dm_property_type`, `dm_host_neighbourhood` (views, SCD2 date-range join) |

`macros/generate_schema_name.sql` makes `schema='silver'` / `schema='gold'` resolve to those schema names instead of being prefixed with the target schema.

## Running

The production job (`Assignment 3 pipeline`) runs these steps in order after each monthly
Airflow load:

```
dbt run --select models/silver
dbt snapshot
dbt run --select models/gold
```

The job is triggered manually; the order matters because the Gold dimensions read from the snapshots.

## Rebuilding snapshot history

If a monthly `dbt snapshot` run is missed, the SCD2 history can be rebuilt deterministically.
Drop the two snapshot tables, then replay the months in order:

```
dbt snapshot --vars '{"snapshot_as_of": "2020-05-01"}'
dbt snapshot --vars '{"snapshot_as_of": "2020-06-01"}'
...
dbt snapshot --vars '{"snapshot_as_of": "2021-04-01"}'
dbt run --select models/gold
```

With no variable passed, the snapshots see every loaded month (normal job behaviour).

## Key conventions

- The reporting period is `file_month` (from the file name), not `scraped_date`.
- Active listing = `has_availability = true`; stays = `30 - availability_30`; estimated revenue = stays × price (active listings only).
- Hosts whose `host_neighbourhood` is blank or does not match a suburb are assigned the LGA `UNKNOWN`.