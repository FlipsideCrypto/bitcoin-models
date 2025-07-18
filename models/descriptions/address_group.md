{% docs address_group %}

An arbitrary group number that identifies addresses within the same entity cluster. This field is the result of Bitcoin address clustering analysis, which groups addresses that are likely controlled by the same entity based on transaction patterns and heuristics. The group number can change over time as clustering algorithms are refined or new transaction patterns are discovered, so avoid referencing specific group numbers in analysis. Instead, use this field to join with other tables to analyze entity-level behavior and transaction patterns. Address clustering is a foundational technique in blockchain analysis that reduces the complexity of analyzing Bitcoin transactions by grouping related addresses together.

{% enddocs %} 