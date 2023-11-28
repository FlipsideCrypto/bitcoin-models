{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = 'tx_id',
    cluster_by = ["_inserted_timestamp::DATE", "_partition_by_block_id"],
    tags = ["core", "scheduled_core"]
) }}
{# 
    incremental_predicates = ['_partition_by_block_id >= (select min(_partition_by_block_id) from ' ~ generate_tmp_view_name(this) ~ ')'],
 #}
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
        tx_id,
        VALUE :metadata :request :params [0] :: STRING AS block_hash,
        VALUE,
        DATA,
        id,
        _inserted_timestamp,
        _partition_by_block_id
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
        t.data: vin [0]: coinbase IS NOT NULL AS is_coinbase,
        t.data: vin [0]: coinbase :: STRING AS coinbase,
        t.data :hash :: STRING AS tx_hash,
        t.data :hex :: STRING AS hex,
        t.data :locktime :: STRING AS lock_time,
        t.data :size :: NUMBER AS SIZE,
        t.data :version :: NUMBER AS version,
        t.data :vin :: ARRAY AS inputs,
        ARRAY_SIZE(inputs) AS input_count,
        t.data :vout :: ARRAY AS outputs,
        {{ target.database }}.silver.udf_sum_vout_values(outputs) AS output_value,
        ARRAY_SIZE(outputs) AS output_count,
        t.data :vsize :: STRING AS virtual_size,
        t.data :weight :: STRING AS weight,
        t.data: fee :: FLOAT AS fee,
        t._partition_by_block_id,
        t._inserted_timestamp
    FROM
        finalized_blocks b
        LEFT JOIN bronze_transactions t USING (
            block_hash,
            tx_id
        )
)
SELECT
    *
FROM
    FINAL
