{{ config(
    materialized = 'incremental',
    unique_key = 'block_number',
    cluster_by = ["_inserted_timestamp::DATE", "block_number"],
    tags = ["core"]
) }}

WITH bronze_blocks AS (

    SELECT
        *
    FROM
        {{ ref('bronze__blocks') }}

{% if is_incremental() %}
WHERE
    _inserted_timestamp >= (
        SELECT
            MAX(_inserted_timestamp) _inserted_timestamp
        FROM
            {{ this }}
    )
{% endif %}
),
FINAL AS (
    SELECT
        block_number,
        DATA :result :bits :: STRING AS bits,
        DATA :result :chainwork :: STRING AS chainwork,
        DATA :result :difficulty :: FLOAT AS difficulty,
        DATA :result :hash :: STRING AS block_hash,
        DATA :result :mediantime :: timestamp_ntz AS median_time,
        DATA :result :merkleroot :: STRING AS merkle_root,
        DATA :result :nTx :: NUMBER AS tx_count,
        DATA :result :nextblockhash :: STRING AS next_block_hash,
        DATA :result :nonce :: NUMBER AS nonce,
        DATA :result :previousblockhash :: STRING AS previous_block_hash,
        DATA :result :strippedsize :: NUMBER AS stripped_size,
        DATA :result :size :: NUMBER AS SIZE,
        DATA :result :time :: timestamp_ntz AS block_timestamp,
        DATA :result :tx :: ARRAY AS tx,
        DATA :result :version :: STRING AS version,
        DATA :result :weight :: STRING AS weight,
        DATA: error :: STRING AS error,
        _partition_by_block_id,
        _inserted_timestamp,
        DATA -- TODO del before prod
    FROM
        bronze_blocks
)
SELECT
    *
FROM
    FINAL
