{{ config(
    materialized = 'view'
) }}
{# SL2.0 integration - add config to send LQ calls through streamline #}
WITH blocks AS (

    SELECT
        block_number,
        block_hash,
        transfer_count,
        _inserted_timestamp
    FROM
        {{ ref('silver_ordinals__transfers_per_block') }}

{% if is_incremental() %}
{# Todo - probably reduce this or just use standard timestamp >= max(timestamp) #}
WHERE
    _inserted_timestamp >= SYSDATE() - INTERVAL '1 DAY'
{% endif %}
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
    {{ ref('silver_ordinals__inscription_transfers') }}
WHERE
    status_code = 200
{% endif %}
)
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
