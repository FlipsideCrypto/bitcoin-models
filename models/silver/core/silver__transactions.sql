{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    incremental_predicates = ['block_number >= (select min(block_number) from ' ~ generate_tmp_view_name(this) ~ ')'],
    unique_key = 'tx_id',
    cluster_by = ["_inserted_timestamp::DATE", "block_number"],
    tags = ["core", "scheduled_core"]
) }}
-- depends_on: {{ ref('silver__blocks') }}
WITH finalized_blocks AS (

    SELECT
        block_number,
        block_hash,
        block_timestamp,
        tx_id,
        INDEX,
        _inserted_timestamp,
        _partition_by_block_id
    FROM
        {{ ref('silver__transaction_index') }}

{% if is_incremental() %}
WHERE
    _inserted_timestamp >= (
        SELECT
            MAX(_inserted_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
),
bronze_transactions AS (
    SELECT
        *
    FROM
        {{ ref('bronze__transactions') }}

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
        b.block_number,
        b.block_hash,
        b.block_timestamp,
        b.tx_id,
        b.index,
        DATA: vin [0]: coinbase IS NOT NULL AS is_coinbase,
        DATA: vin [0]: coinbase :: STRING AS coinbase,
        DATA :hash :: STRING AS tx_hash,
        DATA :hex :: STRING AS hex,
        DATA :locktime :: STRING AS lock_time,
        DATA :size :: NUMBER AS SIZE,
        DATA :version :: NUMBER AS version,
        DATA :vin :: ARRAY AS inputs,
        ARRAY_SIZE(inputs) AS input_count,
        DATA :vout :: ARRAY AS outputs,
        {{ target.database }}.silver.udf_sum_vout_values(outputs) AS output_value,
        ARRAY_SIZE(outputs) AS output_count,
        DATA :vsize :: STRING AS virtual_size,
        DATA :weight :: STRING AS weight,
        DATA: fee :: FLOAT AS fee,
        t.value :metadata :request :params [0] :: STRING AS _request_block_hash,
        t._partition_by_block_id,
        t._inserted_timestamp
    FROM
        finalized_blocks b
        LEFT JOIN transactions t USING (
            block_hash,
            tx_id
        )
)
SELECT
    *
FROM
    FINAL
