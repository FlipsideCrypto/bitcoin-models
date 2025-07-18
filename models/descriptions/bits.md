{% docs bits %}

The nBits field (STRING) from the Bitcoin block header, which encodes the target difficulty for the block. This compact representation stores the difficulty target as a 4-byte value where the first byte is the exponent and the next 3 bytes are the mantissa. The target is calculated as mantissa * 2^(8*(exponent-3)). This field is used by miners to determine if their block hash meets the difficulty requirement and by the network to calculate the actual difficulty value. The nBits field is more compact than storing the full difficulty value and is the standard way Bitcoin represents mining targets.

Example: 1703a30c

{% enddocs %}
