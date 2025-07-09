{% docs tx_id %}

The transaction ID (STRING), a 64-character hexadecimal hash that uniquely identifies this transaction. Note: For SegWit transactions, the txid is calculated without including witness data, which can differ from the transaction hash (see tx_hash).

Example: 4d3c2b1a0f9e8d7c6b5a4e3d2c1b0a9876543210fedcba9876543210fedcba98

See: https://bitcoin.stackexchange.com/questions/77699/whats-the-difference-between-txid-and-hash-getrawtransaction-bitcoind

{% enddocs %}
