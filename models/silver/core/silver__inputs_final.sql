{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    merge_exclude_columns = ["inserted_timestamp"],
    incremental_predicates = ['_partition_by_block_id >= (select min(_partition_by_block_id) from ' ~ generate_tmp_view_name(this) ~ ')'],
    unique_key = 'input_id',
    cluster_by = ["modified_timestamp::DATE", "_partition_by_block_id"],
    tags = ["core", "scheduled_core"],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON equality(block_number, tx_id)"
) }}

{% if execute %}
{% set query %}
    SELECT 
        MIN(_partition_by_block_id) 
    FROM {{ this }} 
    WHERE spent_block_number IS NULL 
        AND NOT is_coinbase
        AND _inserted_timestamp >= DATEADD(day, -3, CURRENT_DATE)
{% endset %}
{% set retry_lookback_value = run_query(query)[0][0] %}
{% do log(retry_lookback_value, info=True) %}
{% endif %}

WITH inputs AS (

    SELECT
        *
    FROM
        {{ ref('silver__inputs') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp) modified_timestamp
        FROM
            {{ this }}
    )
    {% if retry_lookback_value %}
        OR _partition_by_block_id >= {{ retry_lookback_value }}
    {% endif %}
{% endif %}
),
outputs AS (
    SELECT
        tx_id,
        block_number,
        index,
        value,
        value_sats,
        pubkey_script_asm,
        pubkey_script_hex,
        pubkey_script_address,
        pubkey_script_type,
        pubkey_script_desc
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
        o.value_sats,
        i.tx_in_witness,
        i._inserted_timestamp,
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
