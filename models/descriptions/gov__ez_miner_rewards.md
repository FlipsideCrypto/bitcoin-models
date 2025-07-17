{% docs gov__ez_miner_rewards %}

## Description
This table contains comprehensive mining reward data for all Bitcoin blocks, providing detailed breakdowns of block rewards, transaction fees, and total miner compensation. Each row represents a single block with its associated mining economics including the fixed block reward (which halves every 210,000 blocks), transaction fees collected, and the total reward received by the miner. This table is essential for understanding Bitcoin's mining economics, fee market dynamics, and the financial incentives that secure the network.

## Key Use Cases
- Mining economics analysis and profitability studies
- Block reward halving event analysis and impact assessment
- Transaction fee market analysis and blockspace economics
- Mining pool revenue tracking and performance comparison
- Network security analysis through mining incentive monitoring
- Historical mining reward trends and Bitcoin emission analysis
- Fee market dynamics and transaction prioritization studies

## Important Relationships
- Aggregates mining reward data from `core__fact_blocks` and `core__fact_transactions`
- Provides mining economics context for `core__fact_clustered_transfers` entity analysis
- Supports `stats__ez_core_metrics_hourly` for aggregated mining metrics
- Enables integration with `core__dim_entity_clusters` for mining pool analysis
- Complements `price__ez_prices_hourly` for mining profitability analysis

## Commonly-used Fields
- `block_timestamp`: Essential for time-series analysis and trend detection
- `block_number`: Critical for chronological ordering and halving event analysis
- `total_reward`: Key metric for mining profitability and network security analysis
- `block_reward`: Important for Bitcoin emission analysis and halving studies
- `fees`: Essential for fee market analysis and blockspace economics
- `coinbase_decoded`: Critical for mining pool identification and attribution

{% enddocs %} 