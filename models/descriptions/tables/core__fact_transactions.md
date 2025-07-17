{% docs core__fact_transactions %}

## Description
This table contains the canonical record of all confirmed Bitcoin transactions, providing comprehensive transaction-level data including block context, transaction identifiers, input/output details, fees, and raw transaction data. Each row represents a single transaction with complete UTXO information, fee calculations, and transaction metadata. The model aggregates data from upstream silver-layer models and includes computed fields such as transaction fees, input/output value totals, and coinbase status. All values are standardized to Bitcoin conventions (BTC and Satoshis), making this the primary source for Bitcoin transaction analytics.

## Key Use Cases
- Transaction flow analysis and UTXO tracing across the Bitcoin network
- Fee market analysis and blockspace utilization studies
- Address and entity behavior pattern recognition
- Forensic analysis and transaction graph reconstruction
- Network activity monitoring and transaction volume analysis
- Coinbase transaction analysis and mining reward tracking
- Cross-transaction correlation and clustering analysis

## Important Relationships
- Primary source for all transaction-level analytics in the Bitcoin ecosystem
- Referenced by `core.fact_inputs` and `core.fact_outputs` for detailed UTXO analysis
- Supports `core.fact_clustered_transfers` for entity-level transfer tracking
- Used by `core.dim_entity_clusters` for address clustering and entity identification
- Provides transaction data for `stats.ez_core_metrics_hourly` aggregated metrics
- Enables integration with `core.dim_labels` for categorized transaction analysis

## Commonly-used Fields
- `block_timestamp`: Essential for time-series analysis and trend detection
- `tx_hash`: Critical for transaction identification and verification
- `fee`: Key metric for fee market analysis and transaction prioritization
- `input_value` and `output_value`: Core fields for value flow analysis
- `inputs` and `outputs`: Critical for UTXO tracing and transaction reconstruction
- `is_coinbase`: Important for distinguishing mining rewards from regular transactions
- `size` and `virtual_size`: Essential for blockspace analysis and fee calculations

{% enddocs %} 