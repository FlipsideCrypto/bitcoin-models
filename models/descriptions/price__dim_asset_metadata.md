{% docs price__dim_asset_metadata %}

## Description
This table contains comprehensive asset metadata for Bitcoin and other assets from multiple price providers, providing detailed information about asset identifiers, names, symbols, and blockchain associations. Each row represents a single asset with its associated metadata including provider-specific identifiers, token addresses, and blockchain information. This dimension table serves as the foundation for price data analysis, enabling asset identification and categorization across different price providers and blockchain networks.

## Key Use Cases
- Asset identification and metadata lookup across multiple price providers
- Cross-provider price data analysis and comparison
- Asset categorization and blockchain-specific analysis
- Token address mapping and asset verification
- Price provider data quality assessment and validation
- Asset discovery and metadata enrichment for analytics
- Multi-chain asset tracking and relationship mapping

## Important Relationships
- Primary dimension table for asset identification in the price ecosystem
- Referenced by `price__fact_prices_ohlc_hourly` for asset-specific price data
- Supports `price__ez_asset_metadata` for curated asset information
- Used by `price__ez_prices_hourly` for simplified price analysis
- Enables integration with `core__fact_transactions` for asset-specific transaction analysis
- Provides asset context for `stats__ez_core_metrics_hourly` aggregated metrics

## Commonly-used Fields
- `asset_id`: Essential for unique asset identification across providers
- `symbol`: Core field for asset recognition and market analysis
- `token_address`: Critical for blockchain-specific asset identification
- `blockchain`: Important for multi-chain asset categorization
- `provider`: Key for data source attribution and quality assessment
- `name`: Essential for human-readable asset identification

{% enddocs %} 