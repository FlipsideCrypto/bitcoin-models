{% docs merkle_root %}

The Merkle root hash (STRING) of all transactions in the block, computed using a binary hash tree (Merkle tree). The Merkle root is calculated by hashing pairs of transaction hashes recursively until a single hash remains. This structure allows for efficient verification of transaction inclusion in a block without downloading all transaction data. The Merkle root serves as a cryptographic commitment to all transactions in the block and is included in the block header. It enables lightweight clients to verify transaction inclusion using Merkle proofs, which is essential for Simplified Payment Verification (SPV) in Bitcoin.

Example: 3ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a

{% enddocs %}
