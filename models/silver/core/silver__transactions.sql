{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    incremental_predicates = ['block_number >= (select min(block_number) from ' ~ generate_tmp_view_name(this) ~ ')'],
    unique_key = 'tx_id',
    cluster_by = ["modified_timestamp::DATE", "block_number"],
    tags = ["core", "scheduled_core"]
) }}

WITH transactions AS (

    SELECT
        block_number,
        block_hash,
        block_header,
        transactions,
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
flatten_transactions AS (
    SELECT
        block_number,
        block_header :hash :: STRING AS block_hash,
        block_header :time :: timestamp_ntz AS block_timestamp,
        VALUE :txid :: STRING AS tx_id,
        INDEX,
        VALUE :: VARIANT AS tx_data,
        _partition_by_block_id,
        _inserted_timestamp
    FROM 
        transactions,
        LATERAL FLATTEN(input => transactions)
),
FINAL AS (
    SELECT
        block_number,
        block_hash,
        block_timestamp,
        tx_id,
        index,
        tx_data: vin [0]: coinbase IS NOT NULL AS is_coinbase,
        tx_data: vin [0]: coinbase :: STRING AS coinbase,
        tx_data :hash :: STRING AS tx_hash,
        tx_data :hex :: STRING AS hex,
        tx_data :locktime :: STRING AS lock_time,
        tx_data :size :: NUMBER AS SIZE,
        tx_data :version :: NUMBER AS version,
        tx_data :vin :: ARRAY AS inputs,
        ARRAY_SIZE(inputs) AS input_count,
        tx_data :vout :: ARRAY AS outputs,
        {{ target.database }}.silver.udf_sum_vout_values(outputs) AS output_value_agg,
        to_decimal(output_value_agg, 17, 8) AS OUTPUT_VALUE,
        (to_decimal(output_value_agg, 17, 8) * pow(10,8)) :: INTEGER as OUTPUT_VALUE_SATS,
        ARRAY_SIZE(outputs) AS output_count,
        tx_data :vsize :: STRING AS virtual_size,
        tx_data :weight :: STRING AS weight,
        tx_data: fee :: FLOAT AS fee,
        _partition_by_block_id,
        _inserted_timestamp
    FROM
        flatten_transactions
)
SELECT
    *,
    {{ dbt_utils.generate_surrogate_key(
        ['tx_id']
    ) }} AS transactions_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    FINAL
