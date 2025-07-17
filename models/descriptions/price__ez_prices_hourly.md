{% docs price__ez_prices_hourly %}

## Description
This table contains curated hourly price data for Bitcoin and other assets, providing a simplified view of market prices with one price per hour per unique asset and blockchain. Each row represents a single asset's price for a specific hour, including the closing price in USD and associated metadata. This easy view aggregates data from multiple price providers and applies curation logic to ensure data quality and consistency, making it the preferred table for price analysis in most analytical scenarios.

## Key Use Cases
- Simplified price analysis and market trend identification
- Asset valuation and market performance tracking
- Price impact analysis for blockchain events and transactions
- Cross-asset price comparison and correlation studies
- Historical price data for backtesting and modeling
- Market analysis and reporting for dashboards
- Price-based filtering and analysis of blockchain activity

## Important Relationships
- Curated view of `price__fact_prices_ohlc_hourly` with provider prioritization
- Referenced by `price__ez_asset_metadata` for asset-specific context
- Supports `core__fact_transactions` for price-impact analysis
- Used by `core__fact_clustered_transfers` for value-based transfer analysis
- Enables integration with `stats__ez_core_metrics_hourly` for price-based metrics
- Provides curated price context for all market-related analytics

## Commonly-used Fields
- `hour`: Essential for time-series analysis and chronological ordering
- `price`: Core field for market analysis and value calculations
- `symbol`: Critical for asset identification and market analysis
- `blockchain`: Important for multi-chain price comparison
- `token_address`: Key for blockchain-specific asset identification
- Curated price data ensures consistency and quality across analyses

{% enddocs %} 