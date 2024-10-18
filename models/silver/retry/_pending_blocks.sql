{{ config(
    materialized = 'ephemeral'
) }}



SELECT
    block_number
FROM
    {{ ref('silver__blocks') }}
WHERE
    _inserted_timestamp >= DATEADD(
        'day',
        -3,
        CURRENT_DATE
    )
    AND is_pending
