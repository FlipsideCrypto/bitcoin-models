{% docs stats__ez_core_metrics_hourly %}

## Description
This table contains hourly aggregated metrics for the Bitcoin blockchain, providing comprehensive statistics about network activity, transaction volume, and economic indicators. Each row represents a single hour with aggregated metrics including block counts, transaction counts, unique address counts, and fee totals in both native currency and USD. This easy view simplifies complex blockchain analytics by pre-calculating common metrics, making it ideal for dashboards, reporting, and high-level network analysis.

## Key Use Cases
- Network activity monitoring and trend analysis
- Transaction volume tracking and throughput analysis
- Fee market analysis and economic indicator monitoring
- Network health assessment and performance tracking
- Dashboard creation and real-time monitoring
- Historical trend analysis and network growth studies
- Comparative analysis across different time periods

## Important Relationships
- Aggregates data from `core.fact_blocks` and `core.fact_transactions`
- Utilizes `price.ez_prices_hourly` for USD fee calculations
- Supports `core.fact_clustered_transfers` for entity-level metrics
- Enables integration with `gov.ez_miner_rewards` for mining economics
- Provides aggregated context for all other Bitcoin analytics
- Serves as the primary source for network-level reporting

## Commonly-used Fields
- `block_timestamp_hour`: Essential for time-series analysis and trend detection
- `transaction_count`: Core metric for network activity and throughput analysis
- `total_fees_usd`: Key economic indicator for fee market analysis
- `block_count`: Important for network performance and block time analysis
- `unique_from_count` and `unique_to_count`: Critical for address activity analysis
- `total_fees_native`: Essential for native currency fee analysis

{% enddocs %} 