{% docs difficulty %}

The mining difficulty (FLOAT) of the block, representing the estimated amount of work required to find this block relative to the difficulty of finding the genesis block (block 0). Bitcoin's difficulty adjusts every 2,016 blocks (approximately every 2 weeks) to maintain a target block time of 10 minutes. Higher difficulty values indicate that more computational work is required to mine new blocks, which occurs when more miners join the network. Lower difficulty values occur when miners leave the network. The difficulty is calculated using the nBits field and represents the target hash threshold that a block's hash must be below to be considered valid.

Example: 67,305,060,903,803.0

{% enddocs %}
