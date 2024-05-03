{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    merge_exclude_columns = ["inserted_timestamp"],
    unique_key = 'get_transfers_id',
    cluster_by = ["block_number"],
    tags = ["hiro_api"]
) }}
{# todo - create block partition for cluster? #}
WITH bronze_data AS (

    SELECT
        block_number,
        block_hash,
        offset,
        response :data :: variant AS response,
        ARRAY_SIZE(
            response :data :results :: ARRAY
        ) AS result_count,
        response :status_code AS status_code,
        _inserted_timestamp,
        'livequery' AS source
    FROM
        {{ source(
            'bronze_api',
            'get_transfers_response'
        ) }}

{% if is_incremental() %}
WHERE
    _inserted_timestamp >= (
        SELECT
            MAX(_inserted_timestamp)
        FROM
            {{ this }}
    )
{% endif %}

{% if var(
        'BACKFILL_ORDINALS_TRANSFERS',
        False
    ) %}
UNION ALL
SELECT
    block_number,
    NULL AS block_hash,
    offset,
    response,
    result_count,
    status_code,
    request_timestamp AS _inserted_timestamp,
    'backfill' AS source
FROM
    {{ source(
        'bronze_api',
        'get_transfers_response_backfill'
    ) }}
{% endif %}
)
SELECT
    concat_ws(
        '-',
        block_number,
        offset
    ) AS request_id,
    block_number,
    block_hash,
    source,
    offset,
    result_count,
    response,
    status_code,
    _inserted_timestamp,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['block_number', 'offset']
    ) }} AS get_transfers_id,
    '{{ invocation_id }}' AS _invocation_id
FROM
    bronze_data
