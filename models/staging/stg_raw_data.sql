-- stg_raw_data.sql
-- Staging model: cleans and standardizes raw stock data from Snowflake

WITH source AS (
    SELECT * FROM {{ source('raw', 'RAW_STOCK_DATA') }}
),

renamed AS (
    SELECT
        DATE                        AS trade_date,
        TICKER                      AS ticker_symbol,
        ROUND(OPEN, 4)              AS open_price,
        ROUND(HIGH, 4)              AS high_price,
        ROUND(LOW, 4)               AS low_price,
        ROUND(CLOSE, 4)             AS close_price,
        VOLUME                      AS volume,
        LOADED_AT                   AS loaded_at
    FROM source
    WHERE DATE IS NOT NULL
      AND CLOSE IS NOT NULL
      AND VOLUME > 0
)

SELECT * FROM renamed
