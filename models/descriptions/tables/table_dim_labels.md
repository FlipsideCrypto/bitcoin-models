{% docs table_dim_labels %}

## Description
This table contains comprehensive address labels for Bitcoin addresses, providing categorized identification and classification of known entities, contracts, and addresses across the Bitcoin ecosystem. Each row represents a single address with its associated label information including type, subtype, project name, and creator details. The labels are sourced from both automatic algorithms and manual curation, enabling rich categorization of Bitcoin addresses for enhanced analytics and entity identification.

## Key Use Cases
- Address categorization and entity identification across the Bitcoin network
- Exchange and service provider wallet identification and monitoring
- Contract and protocol address tracking and analysis
- Risk assessment and compliance monitoring for specific address types
- Entity-based transaction filtering and analysis
- Community-driven address labeling and verification
- Cross-protocol address relationship mapping

## Important Relationships
- Primary dimension table for address categorization across the Bitcoin ecosystem
- Referenced by `core.fact_transactions` for labeled transaction analysis
- Used by `core.fact_inputs` and `core.fact_outputs` for labeled UTXO analysis
- Supports `core.fact_clustered_transfers` for entity-level transfer categorization
- Enables integration with `core.dim_entity_clusters` for enhanced entity analysis
- Provides categorization context for `stats.ez_core_metrics_hourly` aggregated metrics

## Commonly-used Fields
- `address`: Essential for joining with transaction and UTXO tables
- `label_type`: Core field for high-level address categorization
- `label_subtype`: Important for detailed address classification
- `project_name`: Key for protocol and service provider identification
- `address_name`: Critical for human-readable address identification
- Label fields enable rich categorization and filtering across all Bitcoin data

{% enddocs %}
