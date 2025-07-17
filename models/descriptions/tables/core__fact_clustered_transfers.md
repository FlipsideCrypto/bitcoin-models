{% docs core__fact_clustered_transfers %}

## Description
This table contains Bitcoin transfers between clustered entities, providing a simplified view of fund flows at the entity level rather than individual addresses. Each row represents a transfer between two distinct entities (such as exchanges, miners, or other identified clusters) with aggregated value and transaction information. The model applies address clustering algorithms to group related addresses into entities, enabling high-level analysis of fund movements between major Bitcoin ecosystem participants. This table updates daily as the clustering process identifies new relationships and refines existing entity groupings.

## Key Use Cases
- Entity-level fund flow analysis and exchange activity monitoring
- Large-scale Bitcoin movement tracking between major ecosystem participants
- Exchange inflow/outflow analysis and liquidity studies
- Mining pool reward distribution and fee collection analysis
- Institutional Bitcoin flow monitoring and whale movement detection
- Cross-entity relationship analysis and network mapping
- Simplified transaction graph analysis for high-level insights

## Important Relationships
- Provides entity-level aggregation of `core.fact_transactions` data
- Utilizes `core.dim_entity_clusters` for address-to-entity mapping
- Supports `core.dim_labels` for entity categorization and labeling
- Enables integration with `stats.ez_core_metrics_hourly` for aggregated metrics
- Complements `gov.ez_miner_rewards` for mining-related entity analysis
- Provides simplified view for `price.ez_prices_hourly` market analysis

## Commonly-used Fields
- `block_timestamp`: Essential for time-series analysis and trend detection
- `from_entity` and `to_entity`: Core fields for entity-level flow analysis
- `transfer_amount`: Key metric for value flow analysis and economic studies
- `tx_id`: Critical for linking to detailed transaction information
- `block_number`: Important for chronological ordering and gap detection
- Entity fields enable high-level analysis without address-level complexity

{% enddocs %} 