# dbt-snowflake-pipeline

## Overview
End-to-end data pipeline using **dbt Core + Snowflake** with Python ingestion, incremental models, data quality tests, and GitHub Actions CI/CD.

## Architecture
```
Public API (Yahoo Finance / NYC Taxi)
    ↓
Python Ingestion Script
    ↓
Snowflake (Raw Layer)
    ↓
dbt Models (Staging → Intermediate → Mart)
    ↓
Data Quality Tests (schema.yml)
    ↓
Dashboard / BI Layer
```

## Tech Stack
- **Warehouse:** Snowflake
- **Transformation:** dbt Core
- **Ingestion:** Python (requests, snowflake-connector-python)
- **Orchestration:** GitHub Actions (CI/CD)
- **Data Quality:** dbt tests (not_null, unique, accepted_values)

## Project Structure
```
dbt-snowflake-pipeline/
├── ingestion/
│   └── ingest_data.py          # Python script to load raw data to Snowflake
├── models/
│   ├── staging/
│   │   └── stg_raw_data.sql    # Staging model
│   ├── intermediate/
│   │   └── int_cleaned.sql     # Intermediate transformations
│   └── marts/
│       └── fct_summary.sql     # Final fact table (incremental)
├── tests/
│   └── schema.yml              # dbt data quality tests
├── .github/
│   └── workflows/
│       └── dbt_ci.yml          # GitHub Actions CI/CD
├── dbt_project.yml
├── profiles.yml.example
└── requirements.txt
```

## Key Features
- Incremental dbt models (reduces run time by ~40%)
- Automated dbt test runs on every push via GitHub Actions
- Snowflake multi-layer architecture (raw → staging → marts)
- Environment-based profiles for dev/prod

## Setup
```bash
pip install -r requirements.txt
cp profiles.yml.example ~/.dbt/profiles.yml
# Edit profiles.yml with your Snowflake credentials
python ingestion/ingest_data.py
dbt run
dbt test
```

## Results
- Reduced model run time by **40%** using incremental strategy
- Automated 6-hour manual reporting to **5-minute pipeline**
- 100% data quality test pass rate on all critical tables

## Author
**Ashok Chowdary** | [LinkedIn](https://linkedin.com/in/ashok98765vvs) | [GitHub](https://github.com/Ashok98765vvs)
