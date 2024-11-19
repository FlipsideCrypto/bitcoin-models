{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'block_number',
    cluster_by = ["_inserted_timestamp::DATE", "_partition_by_block_id"],
    tags = ["load", "scheduled_core"]
) }}
-- depends on {{ ref('bronze__streamline_blocks_transactions') }}
-- depends on {{ ref('bronze__streamline_FR_blocks_transactions') }}
WITH streamline_response AS (

    SELECT
        VALUE :BLOCK_NUMBER :: INT AS block_number,
        VALUE :BLOCK_HASH :: STRING AS block_hash,
        OBJECT_DELETE(DATA :result, 'tx') as block_header,
        DATA :result :tx :: ARRAY as transactions,
        DATA :result :nextblockhash :: STRING IS NULL as is_pending,
        _inserted_timestamp,
        _partition_by_block_id
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
{% else %}
    {{ ref('bronze__streamline_FR_blocks_transactions') }}
{% endif %}
)
SELECT
    block_number,
    block_hash,
    block_header,
    transactions,
    is_pending,
    _inserted_timestamp,
    _partition_by_block_id,
    {{ dbt_utils.generate_surrogate_key(
        ['block_number']
    ) }} AS blocks_transactions_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    streamline_response
    qualify ROW_NUMBER() over (
        PARTITION BY block_number
        ORDER BY
            _inserted_timestamp DESC
    ) = 1
