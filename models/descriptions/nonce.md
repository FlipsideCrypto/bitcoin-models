{% docs nonce %}

The nonce value (NUMBER) used by miners to find a valid block hash that meets the difficulty target. The nonce is a 32-bit field in the block header that miners increment to generate different block hashes. When combined with the block's other header fields (version, previous block hash, merkle root, timestamp, bits), the nonce allows miners to create unique block hashes. Miners systematically try different nonce values until they find one that produces a block hash below the target difficulty threshold. The nonce field is the primary mechanism that enables proof-of-work mining in Bitcoin, as it provides the variable input needed to generate different hash outputs.

Example: 1234567890

{% enddocs %}
