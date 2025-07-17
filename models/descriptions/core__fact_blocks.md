{% docs core__fact_blocks %}

## Description
This table contains the complete block header data for all Bitcoin blocks, providing the foundational blockchain structure information. Each row represents a single block with its associated metadata including mining difficulty, proof-of-work parameters, transaction counts, and cryptographic commitments. The data includes all essential block header fields such as timestamp, hash, difficulty, nonce, and Merkle root, which are critical for understanding Bitcoin's consensus mechanism and blockchain integrity.

## Key Use Cases
- Mining difficulty analysis and network hash rate trends
- Block time analysis and network performance monitoring
- Blockchain fork detection and chain validation
- Transaction throughput analysis by block
- Mining pool performance and block discovery patterns
- Network security analysis through proof-of-work metrics
- Historical blockchain growth and development tracking

## Important Relationships
- Primary source for all block-level analytics in the Bitcoin ecosystem
- Referenced by `core__fact_transactions` to provide block context for transaction analysis
- Used by `core__fact_inputs` and `core__fact_outputs` to establish block-level relationships
- Supports `gov__ez_miner_rewards` for mining reward calculations and analysis
- Provides foundational data for `stats__ez_core_metrics_hourly` aggregated metrics

## Commonly-used Fields
- `block_timestamp`: Essential for time-series analysis and trend detection
- `block_number`: Primary field for chronological ordering and gap detection
- `block_hash`: Critical for blockchain integrity verification and fork analysis
- `difficulty`: Key metric for understanding network security and mining economics
- `tx_count`: Important for transaction throughput and network activity analysis
- `chainwork`: Essential for determining the canonical chain in fork scenarios
- `merkle_root`: Critical for transaction inclusion verification and SPV operations

{% enddocs %} 