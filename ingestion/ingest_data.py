import os
import requests
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from datetime import datetime

# ── Snowflake connection config (use env vars in production) ──────────────────
SF_CONFIG = {
    "user":       os.getenv("SNOWFLAKE_USER"),
    "password":   os.getenv("SNOWFLAKE_PASSWORD"),
    "account":    os.getenv("SNOWFLAKE_ACCOUNT"),
    "warehouse":  os.getenv("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
    "database":   os.getenv("SNOWFLAKE_DATABASE", "RAW_DB"),
    "schema":     os.getenv("SNOWFLAKE_SCHEMA", "PUBLIC"),
}

RAW_TABLE = "RAW_STOCK_DATA"

# ── Fetch data from public API (Yahoo Finance via yfinance) ───────────────────
def fetch_stock_data(ticker: str = "AAPL", period: str = "1mo") -> pd.DataFrame:
    import yfinance as yf
    df = yf.download(ticker, period=period, interval="1d").reset_index()
    df.columns = [c.upper() for c in df.columns]
    df["TICKER"] = ticker
    df["LOADED_AT"] = datetime.utcnow()
    return df

# ── Load DataFrame to Snowflake raw table ────────────────────────────────────
def load_to_snowflake(df: pd.DataFrame) -> None:
    conn = snowflake.connector.connect(**SF_CONFIG)
    success, nchunks, nrows, _ = write_pandas(
        conn, df, RAW_TABLE, auto_create_table=True, overwrite=False
    )
    conn.close()
    print(f"Loaded {nrows} rows in {nchunks} chunks. Success: {success}")

# ── Entrypoint ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("Fetching stock data...")
    df = fetch_stock_data(ticker="AAPL", period="3mo")
    print(f"Fetched {len(df)} rows")
    load_to_snowflake(df)
    print("Done!")
