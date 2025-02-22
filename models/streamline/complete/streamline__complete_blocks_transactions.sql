-- depends_on: {{ ref('bronze__streamline_blocks_transactions') }}
-- depends_on: {{ ref('bronze__streamline_FR_blocks_transactions') }}
{{ config (
    materialized = "incremental",
    incremental_strategy = "merge",
    merge_exclude_columns = ["inserted_timestamp"],
    unique_key = "block_number",
    cluster_by = "partition_key",
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION on equality(block_number)",
    tags = ['streamline_complete']
) }}

SELECT
    VALUE :BLOCK_NUMBER :: INT AS block_number,
    VALUE :BLOCK_HASH :: STRING AS block_hash,
    DATA :result :nextblockhash :: STRING IS NULL AS is_pending,
    partition_key,
    _inserted_timestamp,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM

{% if is_incremental() %}
{{ ref('bronze__streamline_blocks_transactions') }}
WHERE
    _inserted_timestamp >= (
        SELECT
            MAX(_inserted_timestamp) _inserted_timestamp
        FROM
            {{ this }}
    )
    AND partition_key >= (
        SELECT
            MAX(partition_key) partition_key
        FROM
            {{ this }}
    ) -1000 -- get the previous partition_key to be safe
{% else %}
    {{ ref('bronze__streamline_FR_blocks_transactions') }}
{% endif %}

qualify(ROW_NUMBER() over (PARTITION BY block_number
ORDER BY
    _inserted_timestamp DESC)) = 1
