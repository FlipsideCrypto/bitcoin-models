{% docs inputs %}

An array of input objects (ARRAY<STRUCT>) for this transaction. Each object represents a transaction input (vin), including fields such as previous output reference, scriptSig, and sequence number.

Example: [ {"txid": "...", "vout": 0, "scriptSig": { ... }, "sequence": 4294967295 }, ... ]

{% enddocs %}
