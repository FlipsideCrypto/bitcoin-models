{% docs price__fact_prices_ohlc_hourly %}

## Description
This table contains comprehensive hourly OHLC (Open, High, Low, Close) price data for Bitcoin and other assets from multiple price providers, providing detailed market information for each hour. Each row represents a single asset's price data for a specific hour, including opening, highest, lowest, and closing prices in USD. This fact table serves as the raw price data foundation, enabling detailed market analysis, volatility studies, and price trend analysis across different time periods and assets.

## Key Use Cases
- Hourly price analysis and market trend identification
- Volatility analysis and price movement studies
- Cross-provider price comparison and data quality assessment
- Technical analysis and chart pattern recognition
- Market performance tracking and benchmarking
- Price impact analysis for blockchain events
- Historical price data for backtesting and modeling

## Important Relationships
- Primary fact table for hourly price data in the price ecosystem
- Referenced by `price__dim_asset_metadata` for asset identification
- Supports `price__ez_prices_hourly` for curated price analysis
- Used by `price__ez_asset_metadata` for asset-specific price context
- Enables integration with `core__fact_transactions` for price-impact analysis
- Provides price context for `stats__ez_core_metrics_hourly` aggregated metrics

## Commonly-used Fields
- `hour`: Essential for time-series analysis and chronological ordering
- `asset_id`: Critical for asset-specific price analysis and filtering
- `open`, `high`, `low`, `close`: Core fields for OHLC price analysis
- `close`: Key metric for end-of-period price analysis and trend detection
- `high` and `low`: Important for volatility analysis and price range studies
- `open`: Essential for price gap analysis and market opening studies

{% enddocs %} 