{{ config(
    materialized = 'incremental',
    unique_key = 'tx_id',
    incremental_strategy = 'delete+insert',
    cluster_by = ["_partition_by_block_id", "tx_id"],
    tags = ["core"]
) }}

WITH blocks AS (

    SELECT
        *
    FROM
        {{ ref('silver__blocks') }}

{% if is_incremental() %}
WHERE
_partition_by_block_id >= 803000
{% endif %}
),
FINAL AS (
    SELECT
        block_number,
        block_hash,
        block_timestamp,
        VALUE :: STRING AS tx_id,
        INDEX,
        _inserted_timestamp,
        _partition_by_block_id
    FROM
        blocks,
        LATERAL FLATTEN(tx)
)
SELECT
    *
FROM
    FINAL
