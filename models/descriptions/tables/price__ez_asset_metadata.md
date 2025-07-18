{% docs price__ez_asset_metadata %}

## Description
This table contains curated and prioritized asset metadata for Bitcoin and other assets, providing a simplified view of asset information with one unique asset per blockchain. Each row represents a single asset with its associated metadata including name, symbol, token address, and blockchain information. This easy view aggregates data from multiple price providers and applies curation logic to ensure data quality and consistency, making it the preferred table for asset identification and metadata lookup in most analytical scenarios.

## Key Use Cases
- Simplified asset identification and metadata lookup
- Cross-blockchain asset analysis and comparison
- Token address mapping and asset verification
- Asset discovery and categorization for analytics
- Price data integration with blockchain transaction analysis
- Multi-chain asset tracking and relationship mapping
- Curated asset information for reporting and dashboards

## Important Relationships
- Curated view of `price.dim_asset_metadata` with provider prioritization
- Referenced by `price.ez_prices_hourly` for asset-specific price analysis
- Supports `core.fact_transactions` for asset-specific transaction analysis
- Used by `core.fact_clustered_transfers` for asset-based transfer categorization
- Enables integration with `stats.ez_core_metrics_hourly` for asset-specific metrics
- Provides curated asset context for all price-related analytics

## Commonly-used Fields
- `symbol`: Essential for asset recognition and market analysis
- `token_address`: Critical for blockchain-specific asset identification
- `blockchain`: Important for multi-chain asset categorization
- `name`: Essential for human-readable asset identification
- `asset_id`: Key for unique asset identification and relationship mapping
- Curated fields ensure data quality and consistency across analyses

{% enddocs %} 