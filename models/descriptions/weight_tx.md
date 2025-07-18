{% docs weight_tx %}

The transaction's weight (INTEGER, weight units). Calculated as (stripped_size * 3) + total_size, or equivalently, virtual_size * 4. Used for fee calculation and block size limits in Bitcoin.

Example: 564

{% enddocs %}
