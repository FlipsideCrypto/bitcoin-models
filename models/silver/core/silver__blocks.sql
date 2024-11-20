{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    merge_exclude_columns = ["inserted_timestamp"],
    unique_key = 'block_number',
    cluster_by = ["modified_timestamp::DATE", "block_number"],
    tags = ["core", "scheduled_core"]
) }}

WITH blocks AS (

    SELECT
        block_number,
        block_header,
        _inserted_timestamp,
        _partition_by_block_id
    FROM
        {{ ref('silver__blocks_transactions') }}
    WHERE
        NOT is_pending

{% if is_incremental() %}
AND modified_timestamp >= (
    SELECT
        MAX(modified_timestamp) modified_timestamp
    FROM
        {{ this }}
)
{% endif %}
),
FINAL AS (
    SELECT
        block_number,
        block_header :bits :: STRING AS bits,
        block_header :chainwork :: STRING AS chainwork,
        block_header :difficulty :: FLOAT AS difficulty,
        block_header :hash :: STRING AS block_hash,
        block_header :mediantime :: timestamp_ntz AS median_time,
        block_header :merkleroot :: STRING AS merkle_root,
        block_header :nTx :: NUMBER AS tx_count,
        block_header :nextblockhash :: STRING AS next_block_hash,
        block_header :nextblockhash IS NULL AS is_pending,
        block_header :nonce :: NUMBER AS nonce,
        block_header :previousblockhash :: STRING AS previous_block_hash,
        block_header :strippedsize :: NUMBER AS stripped_size,
        block_header :size :: NUMBER AS SIZE,
        block_header :time :: timestamp_ntz AS block_timestamp,
        [] AS tx, -- note, is just array of tx ids in curr table
        block_header :version :: STRING AS version,
        block_header :weight :: STRING AS weight,
        block_header :error :: STRING AS error,
        _partition_by_block_id,
        _inserted_timestamp,
        {{ dbt_utils.generate_surrogate_key(
            ['block_number']
        ) }} AS blocks_id,
        SYSDATE() AS inserted_timestamp,
        SYSDATE() AS modified_timestamp,
        '{{ invocation_id }}' AS _invocation_id
    FROM
        blocks
)
SELECT
    *
FROM
    FINAL
