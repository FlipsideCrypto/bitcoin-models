{% docs core__dim_entity_clusters %}

## Description
This table contains address clustering information that groups related Bitcoin addresses into entities based on common spending patterns and behavioral analysis. Each row represents a single address with its associated cluster group and optional project label. The clustering algorithm identifies addresses that are likely controlled by the same entity (such as exchanges, mining pools, or other organizations) by analyzing transaction patterns, input/output relationships, and spending behaviors. This dimension table enables entity-level analysis across all Bitcoin transaction data.

## Key Use Cases
- Entity-level transaction analysis and address grouping
- Exchange and service provider activity monitoring
- Mining pool identification and reward tracking
- Institutional Bitcoin holder analysis and whale identification
- Address clustering for privacy analysis and deanonymization studies
- Cross-address relationship mapping and network analysis
- Entity-based risk assessment and compliance monitoring

## Important Relationships
- Primary dimension table for entity-level analytics across the Bitcoin ecosystem
- Referenced by `core.fact_clustered_transfers` for entity-to-entity transfer analysis
- Supports `core.fact_transactions` for entity-level transaction filtering
- Used by `core.fact_inputs` and `core.fact_outputs` for entity-based UTXO analysis
- Enables integration with `core.dim_labels` for categorized entity analysis
- Provides entity context for `stats.ez_core_metrics_hourly` aggregated metrics

## Commonly-used Fields
- `address`: Essential for joining with transaction and UTXO tables
- `address_group`: Core field for entity identification and grouping
- `project_name`: Important for entity categorization and labeled analysis
- Address grouping enables entity-level aggregation across all Bitcoin data

{% enddocs %} 