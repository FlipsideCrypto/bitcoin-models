{{ config(
    materialized = 'ephemeral'
) }}

SELECT
    block_number
FROM
    {{ ref('streamline__complete_blocks_transactions') }}
WHERE
    is_pending

    {% if not var('STREAMLINE_RUN_HISTORY') %}
    AND _inserted_timestamp >= DATEADD(
        'day',
        -3,
        CURRENT_DATE
    )
{% endif %}
