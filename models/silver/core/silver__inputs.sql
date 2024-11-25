{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    merge_exclude_columns = ["inserted_timestamp"],
    incremental_predicates = ['block_number >= (select min(block_number) from ' ~ generate_tmp_view_name(this) ~ ')'],
    unique_key = 'input_id',
    tags = ["core", "scheduled_core"],
    cluster_by = ["modified_timestamp::DATE", "block_number"]
) }}

WITH txs AS (

    SELECT
        block_number,
        block_hash,
        block_timestamp,
        tx_id,
        inputs,
        coinbase,
        is_coinbase,
        _partition_by_block_id,
        _inserted_timestamp
    FROM
        {{ ref('silver__transactions') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp) modified_timestamp
        FROM
            {{ this }}
    )
{% endif %}
),
flattened_inputs AS (
    SELECT
        t.block_number,
        t.block_hash,
        t.block_timestamp,
        t.tx_id,
        i.value :: variant AS input_data,
        i.index AS INDEX,
        i.value :scriptSig :asm :: STRING AS script_sig_asm,
        i.value :scriptSig :hex :: STRING AS script_sig_hex,
        i.value :sequence :: NUMBER AS SEQUENCE,
        i.value :txid :: STRING AS spent_tx_id,
        i.value :vout :: NUMBER AS spent_output_index,
        i.value :txinwitness :: ARRAY AS tx_in_witness,
        t.coinbase,
        t.is_coinbase,
        t._inserted_timestamp,
        t._partition_by_block_id
    FROM
        txs t,
        LATERAL FLATTEN(inputs) i
)
SELECT
    *,
    {{ dbt_utils.generate_surrogate_key(['block_number', 'tx_id', 'index']) }} AS input_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    flattened_inputs
