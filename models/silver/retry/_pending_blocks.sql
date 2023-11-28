{{ config(
    materialized = 'ephemeral'
) }}

WITH pending_blocks AS (

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
)
SELECT
    block_number,
    -- TODO swap for local deployment of LQ and prod QN url
    livequery.live.udf_api(
        'POST',
        'https://docs-demo.btc.quiknode.pro/',{},{ 'method': 'getblockhash',
        'params': [block_number] }
    ) :data :result :: STRING AS block_hash
FROM
    pending_blocks
