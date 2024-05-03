{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    merge_exclude_columns = ["inserted_timestamp"],
    unique_key = 'get_transfers_id',
    cluster_by = ["block_number"],
    tags = ["hiro_api"],
    enabled = False
) }}
{# If can call a SPROC from a UDF, then this model is cleaner. 
Otherwise, use SP_GET_INSCRIPTION_TRANSFERS to request and build in BRONZE_API schema #}

WITH blocks AS (

    SELECT
        block_number,
        block_hash,
        transfer_count,
        _inserted_timestamp
    FROM
        {{ ref('silver_ordinals__transfers_per_block') }}

{% if is_incremental() %}
WHERE
    _inserted_timestamp >= SYSDATE() - INTERVAL '1 DAY'
{% endif %}
LIMIT
    50
), 
input_spine AS (
    SELECT
        block_number,
        block_hash,
        VALUE :: INT AS offset
    FROM
        blocks,
        LATERAL FLATTEN(
            {{ target.database }}.streamline.udf_generate_offset_array(CEIL(transfer_count / 60))
        )
),
request_ids AS (
    SELECT
        block_number,
        block_hash,
        offset
    FROM
        input_spine

{% if is_incremental() %}
EXCEPT
SELECT
    block_number,
    block_hash,
    offset
FROM
    {{ this }}
WHERE
    status_code = 200
{% endif %}
),
requests AS (
    SELECT
        block_number,
        block_hash,
        offset,
        {{ target.database }}.streamline.udf_get_inscription_transfers_by_block(
            block_hash,
            offset
        ) AS response
    FROM
        request_ids
LIMIT 500
)
SELECT
    concat_ws(
        '-',
        block_number,
        offset
    ) AS request_id,
    block_number,
    block_hash,
    offset,
    ARRAY_SIZE(
        response :data :results :: ARRAY
    ) AS result_count,
    response,
    response :status_code AS status_code,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['block_number', 'offset']
    ) }} AS get_transfers_id,
    '{{ invocation_id }}' AS _invocation_id
FROM
    requests
