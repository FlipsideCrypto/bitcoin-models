{% docs core__fact_outputs %}

## Description
This table contains detailed information about all transaction outputs in the Bitcoin blockchain, representing the newly created UTXOs that result from each transaction. Each row represents a single output with complete metadata including destination address, script information, value data, and spending conditions. The model includes comprehensive script analysis and address information for all output types, making it essential for understanding Bitcoin's UTXO model and tracking the creation of spendable funds across the network.

## Key Use Cases
- UTXO creation analysis and new fund tracking across the Bitcoin network
- Address receiving pattern analysis and fund accumulation studies
- Script type analysis and Bitcoin protocol feature adoption tracking
- Output value distribution analysis and economic studies
- Address clustering and entity identification through receiving patterns
- Change output analysis and transaction structure studies
- Fund flow analysis and destination address tracking

## Important Relationships
- Primary source for output-level analytics in the Bitcoin ecosystem
- Referenced by `core__fact_transactions` to provide output details for transaction analysis
- Links to `core__fact_inputs` when outputs are spent in future transactions
- Supports `core__fact_clustered_transfers` for entity-level transfer tracking
- Used by `core__dim_entity_clusters` for address clustering and entity identification
- Enables integration with `core__dim_labels` for categorized output analysis

## Commonly-used Fields
- `block_timestamp`: Essential for time-series analysis and trend detection
- `tx_id`: Critical for linking outputs to their containing transactions
- `index`: Important for identifying specific outputs within transactions
- `value` and `value_sats`: Key metrics for value analysis and economic studies
- `pubkey_script_address`: Essential for address-based analytics and entity tracking
- `pubkey_script_type`: Important for protocol feature analysis and script usage patterns
- `output_id`: Critical for unique identification and relationship mapping

{% enddocs %} 