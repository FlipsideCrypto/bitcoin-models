{% docs tx_hash %}

The transaction hash (STRING), a 64-character hexadecimal value that uniquely identifies a Bitcoin transaction. This hash is computed by double SHA-256 hashing of the transaction data and serves as the primary identifier for transactions across the Bitcoin network. For SegWit transactions, the transaction hash (wtxid) includes witness data, while the txid does not, which may result in different hash values for the same transaction. This field is essential for transaction verification, blockchain explorers, and cross-referencing transactions across different systems.

Example: 9f8e7d6c5b4a3b2c1d0e1f2a3b4c5d6e7f8g9000000000000000a16b7e2e3b2c

{% enddocs %}
