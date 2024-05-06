{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    merge_exclude_columns = ["inserted_timestamp"],
    unique_key = 'inscription_transfers_id',
    cluster_by = ["_partition_by_block_number"],
    tags = ["hiro_api"]
) }}

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
        'streamline' AS source
    FROM
        {# Ref to view on external table with Streamline responses #}
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
),
flatten_response AS (
    SELECT
        block_number,
        block_hash,
        offset,
        source,
        VALUE :id :: STRING AS inscription_id,
        VALUE :number :: INT AS inscription_number,
        VALUE :from :: variant AS transfer_from_data,
        VALUE :to :: variant AS transfer_to_data,
        _inserted_timestamp
    FROM
        bronze_data,
        LATERAL FLATTEN(
            response :results :: ARRAY
        )
),
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
    _inserted_timestamp,
    ROUND(
        block_number,
        -3
    ) AS _partition_by_block_number,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['block_number', 'inscription_id']
    ) }} AS inscription_transfers_id,
    '{{ invocation_id }}' AS _invocation_id
FROM
    bronze_data

{# Need a qualify statement, probably. #}