{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    merge_exclude_columns = ["inserted_timestamp"],
    incremental_predicates = ['_partition_by_block_id >= (select min(_partition_by_block_id) from ' ~ generate_tmp_view_name(this) ~ ')'],
    unique_key = 'tx_id',
    cluster_by = ["block_timestamp::DATE","_partition_by_block_id"],
    tags = ["core", "scheduled_core"],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON equality(block_number, tx_id)"
) }}

{% if execute %}
    {% set query %}

    SELECT
        MIN(_partition_by_block_id) _partition_by_block_id
    FROM
        {{ ref('silver__inputs_final') }}
    WHERE
        modified_timestamp >= (
            SELECT
                MAX(modified_timestamp) modified_timestamp
            FROM
                {{ this }}
        ) {% endset %}
    {% set incremental_load_value = run_query(query) [0] [0] %}
    {% if not incremental_load_value or incremental_load_value == 'None' %}
        {% set incremental_load_value = (select min(_partition_by_block_id) from {{ this }}) %}
    {% endif %}
{% endif %}

WITH inputs AS (
    SELECT
        block_number,
        tx_id,
        value,
        value_sats
    FROM
        {{ ref('silver__inputs_final') }}

{% if is_incremental() %}
WHERE
    _partition_by_block_id >= {{ incremental_load_value }}
    OR modified_timestamp >= (
        SELECT
            MAX(modified_timestamp) modified_timestamp
        FROM
            {{ this }}
    )
{% endif %}
),
transactions AS (
    SELECT
        block_number,
        block_hash,
        block_timestamp,
        tx_id,
        INDEX,
        tx_hash,
        hex,
        lock_time,
        SIZE,
        version,
        is_coinbase,
        coinbase,
        fee,
        inputs,
        input_count,
        outputs,
        output_count,
        output_value,
        output_value_sats,
        virtual_size,
        weight,
        _partition_by_block_id,
        _inserted_timestamp
    FROM
        {{ ref('silver__transactions') }}

{% if is_incremental() %}
WHERE
    _partition_by_block_id >= {{ incremental_load_value }}
{% endif %}
),
input_val AS (
    SELECT
        block_number,
        tx_id,
        SUM(VALUE) AS input_value,
        SUM(value_sats) AS input_value_sats
    FROM
        inputs
    GROUP BY
        1,
        2
),
transactions_final AS (
    SELECT
        t.block_number,
        block_hash,
        block_timestamp,
        t.tx_id,
        INDEX,
        tx_hash,
        hex,
        lock_time,
        SIZE,
        version,
        is_coinbase,
        coinbase,
        inputs,
        input_count,
        i.input_value,
        i.input_value_sats,
        outputs,
        output_count,
        output_value,
        output_value_sats,
        virtual_size,
        weight,
        IFF(
            is_coinbase,
            0,
            fee
        ) AS fee,
        _partition_by_block_id,
        _inserted_timestamp
    FROM
        transactions t
        LEFT JOIN input_val i USING (
            block_number,
            tx_id
        )
)
SELECT
    *,
    {{ dbt_utils.generate_surrogate_key(
        ['tx_id']
    ) }} AS transactions_final_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    transactions_final
