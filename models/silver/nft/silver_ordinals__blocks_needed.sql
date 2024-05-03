{{ config(
    materialized = 'view'
) }}

WITH blocks AS (

    SELECT
        block_number,
        block_hash,
        transfer_count,
        _inserted_timestamp
    FROM
        {{ ref('silver_ordinals__transfers_per_block') }}
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
)
SELECT
    block_number,
    block_hash,
    offset
FROM
    input_spine
{% if target.profile == 'prod' %}
EXCEPT
SELECT
    block_number,
    block_hash,
    offset
FROM
    {{ target.database }}.silver_ordinals.inscription_transfers
{% else %}
LIMIT 10
{% endif %}
