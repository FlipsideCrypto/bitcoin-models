{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'block_number',
    cluster_by = ["block_timestamp::DATE","round(block_number,-3)"],
    tags = ["core", "ez", "scheduled_non_core" ],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION"
) }}

WITH transactions AS (

    SELECT
        block_timestamp,
        block_hash,
        block_number,
        coinbase,
        fee,
        output_value,
        is_coinbase,
        _inserted_timestamp,
        _partition_by_block_id
    FROM
        {{ ref('silver__transactions') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
    OR block_number IN (
        SELECT
            DISTINCT block_number
        FROM
            {{ this }}
        WHERE
            modified_timestamp >= SYSDATE() - INTERVAL '3 days'
            AND fees IS NULL
    )
{% endif %}
),
tx_value AS (
    SELECT
        block_number,
        SUM(COALESCE(fee, 0)) AS fees
    FROM
        transactions
    GROUP BY
        1
),
coinbase AS (
    SELECT
        block_timestamp,
        block_number,
        block_hash,
        coinbase,
        output_value AS coinbase_value,
        streamline.udf_decode_hex_to_string(coinbase) AS coinbase_decoded,
        _inserted_timestamp,
        _partition_by_block_id
    FROM
        transactions
    WHERE
        is_coinbase
),
blocks_final AS (
    SELECT
        C.block_timestamp,
        v.block_number,
        C.block_hash,
        C.coinbase_value AS total_reward,
        C.coinbase_value - v.fees AS block_reward,
        v.fees,
        C.coinbase,
        C.coinbase_decoded,
        C._partition_by_block_id,
        C._inserted_timestamp
    FROM
        tx_value v
        LEFT JOIN coinbase C USING (block_number)
)
SELECT
    *,
    {{ dbt_utils.generate_surrogate_key(
        ['block_number']
    ) }} AS block_miner_rewards_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    blocks_final
