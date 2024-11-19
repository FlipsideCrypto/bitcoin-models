-- depends_on: {{ ref('bronze__streamline_blocks_hash') }}
-- depends_on: {{ ref('bronze__streamline_FR_blocks_hash') }}
{{ config (
    materialized = "incremental",
    unique_key = "block_number",
    cluster_by = "partition_key",
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION on equality(block_number)"
) }}

SELECT
    VALUE :BLOCK_NUMBER :: INT AS block_number,
    data :result :: STRING AS block_hash,
    partition_key,
    _inserted_timestamp
FROM

{% if is_incremental() %}
{{ ref('bronze__streamline_blocks_hash') }}
WHERE
    _inserted_timestamp >= (
        SELECT
            MAX(_inserted_timestamp) _inserted_timestamp
        FROM
            {{ this }}
    )
{% else %}
    {{ ref('bronze__streamline_FR_blocks_hash') }}
{% endif %}

qualify(ROW_NUMBER() over (PARTITION BY block_number
ORDER BY
    _inserted_timestamp DESC)) = 1
