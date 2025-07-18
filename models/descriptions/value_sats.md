{% docs value_sats %}

The total value (INTEGER, Satoshis) of all inputs or outputs in this transaction, depending on context. Satoshis are the smallest unit of Bitcoin, with 1 BTC = 100,000,000 Satoshis. Using satoshis provides the highest precision for Bitcoin value calculations and avoids floating-point arithmetic issues that can occur with decimal BTC values. This field is essential for precise financial calculations, especially when dealing with small amounts or when aggregating large numbers of transactions where precision is critical.

Example: 12345678

{% enddocs %}
