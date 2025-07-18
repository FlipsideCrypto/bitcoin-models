{% docs chainwork %}

The cumulative proof of work (STRING) required to produce the current blockchain up to this block. Chainwork is the sum of all difficulty values from the genesis block to the current block, representing the total computational effort expended to create the entire blockchain. This field is used to determine the "heaviest" chain in case of forks, as the chain with the highest chainwork is considered the valid one. Chainwork provides a more accurate measure of blockchain security than block height alone, as it accounts for the actual computational effort required to create each block.

Example: 0000000000000000000000000000000000000000000000000000000000000000

{% enddocs %}
