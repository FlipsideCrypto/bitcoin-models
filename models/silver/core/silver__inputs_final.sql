{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    merge_exclude_columns = ["inserted_timestamp"],
    incremental_predicates = ['block_number >= (select min(block_number) from ' ~ generate_tmp_view_name(this) ~ ')'],
    unique_key = 'input_id',
    cluster_by = ["block_number", "tx_id"],
    tags = ["core", "scheduled_core"],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION"
) }}

WITH inputs AS (

    SELECT
        *
    FROM
        {{ ref('silver__inputs') }}

{% if is_incremental() %}
WHERE
    _inserted_timestamp >= (
        SELECT
            MAX(_inserted_timestamp) _inserted_timestamp
        FROM
            {{ this }}
    )
    OR block_number IN (
        SELECT
            DISTINCT block_number
        FROM
            {{ this }}
        WHERE
            is_pending
            AND _inserted_timestamp >= SYSDATE() - INTERVAL '1 day'
    )
{% endif %}
),
outputs AS (
    SELECT
        *
    FROM
        {{ ref('silver__outputs') }}
),
FINAL AS (
    SELECT
        i.block_number,
        i.block_timestamp,
        i.block_hash,
        i.tx_id,
        i.input_data,
        i.index,
        i.is_coinbase,
        i.coinbase,
        i.script_sig_asm,
        i.script_sig_hex,
        i.sequence,
        o.block_number AS spent_block_number,
        i.spent_tx_id,
        i.spent_output_index,
        o.pubkey_script_asm,
        o.pubkey_script_hex,
        o.pubkey_script_address,
        o.pubkey_script_type,
        o.pubkey_script_desc,
        o.value,
        o.block_number IS NULL AS is_pending,
        i.tx_in_witness,
        COALESCE(
            o._inserted_timestamp,
            i._inserted_timestamp
        ) AS _inserted_timestamp,
        i._partition_by_block_id,
        i.input_id
    FROM
        inputs i
        LEFT JOIN outputs o
        ON i.spent_tx_id = o.tx_id
        AND i.spent_output_index = o.index
)
SELECT
    *,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    FINAL
