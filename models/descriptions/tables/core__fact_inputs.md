{% docs core__fact_inputs %}

## Description
This table contains detailed information about all transaction inputs in the Bitcoin blockchain, representing the spent UTXOs that fund each transaction. Each row represents a single input with complete metadata including the source transaction, output index, script information, and value data. The model includes both regular transaction inputs and coinbase inputs (mining rewards), with comprehensive script analysis and address information. This table is essential for understanding Bitcoin's UTXO model and tracing the flow of funds across the network.

## Key Use Cases
- UTXO tracing and transaction flow analysis across the Bitcoin network
- Address behavior analysis and spending pattern recognition
- Coinbase transaction analysis and mining reward tracking
- Script type analysis and Bitcoin protocol feature usage
- Input age analysis and coin consolidation studies
- Forensic analysis and transaction graph reconstruction
- Address clustering and entity identification through spending patterns

## Important Relationships
- Primary source for input-level analytics in the Bitcoin ecosystem
- Referenced by `core.fact_transactions` to provide input details for transaction analysis
- Links to `core.fact_outputs` through spent transaction and output index relationships
- Supports `core.fact_clustered_transfers` for entity-level transfer tracking
- Used by `core.dim_entity_clusters` for address clustering and entity identification
- Enables integration with `core.dim_labels` for categorized input analysis

## Commonly-used Fields
- `block_timestamp`: Essential for time-series analysis and trend detection
- `tx_id`: Critical for linking inputs to their containing transactions
- `spent_tx_id` and `spent_output_index`: Core fields for UTXO tracing and flow analysis
- `value` and `value_sats`: Key metrics for value flow analysis and economic studies
- `pubkey_script_address`: Essential for address-based analytics and entity tracking
- `pubkey_script_type`: Important for protocol feature analysis and script usage patterns
- `is_coinbase`: Critical for distinguishing mining rewards from regular transaction inputs

{% enddocs %} 