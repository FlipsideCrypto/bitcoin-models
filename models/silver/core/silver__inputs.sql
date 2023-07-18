{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'input_id',
    tags = ["core"],
    cluster_by = ["_inserted_timestamp"],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION"
) }}

WITH txs AS (

    SELECT
        *
    FROM
        {{ ref('silver__transactions') }}

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
inputs AS (
    SELECT
        t.block_number,
        t.block_hash,
        t.block_timestamp,
        t.tx_id AS tx_id,
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
        t._partition_by_block_id,
        {{ dbt_utils.generate_surrogate_key(['i.block_number', 'i.tx_id', 'i.index']) }} AS input_id
    FROM
        txs t,
        LATERAL FLATTEN(inputs) i
)
SELECT
    *
FROM
    inputs
