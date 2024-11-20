-- depends_on: {{ ref('streamline__complete_blocks_hash') }}
-- depends_on: {{ ref('streamline__complete_blocks_transactions') }}

{{ config (
    materialized = "view",
    post_hook = fsc_utils.if_data_call_function_v2(
        func = 'streamline.udf_bulk_rest_api_v2',
        target = "{{this.schema}}.{{this.identifier}}",
        params ={ "external_table" :"blocks_transactions_v2",
        "sql_limit" :"250",
        "producer_batch_size" :"50",
        "worker_batch_size" :"50",
        "sql_source" :"{{this.identifier}}" }
    )
) }}

WITH last_3_days AS (
{% if var('STREAMLINE_RUN_HISTORY') %}

    SELECT
        0 AS block_number
    {% else %}
    SELECT
        MAX(block_number) - 500 AS block_number -- approx 3 days
    FROM
        {{ ref("streamline__blocks") }}
    {% endif %}
),
    tbl AS (
        SELECT
            block_number,
            block_hash
        FROM
            {{ ref("streamline__complete_blocks_hash") }}
        WHERE
            (
                block_number >= (
                    SELECT
                        block_number
                    FROM
                        last_3_days
                )
            )
            AND block_number IS NOT NULL
        EXCEPT
        SELECT
            block_number,
            block_hash
        FROM
            {{ ref("streamline__complete_blocks_transactions") }}
        WHERE
            block_number >= (
                SELECT
                    block_number
                FROM
                    last_3_days
            )
            AND block_number IS NOT NULL
            AND NOT is_pending
    )
SELECT
    block_number,
    block_hash,
    ROUND(
        block_number,
        -3
    ) AS partition_key,
    {{ target.database }}.live.udf_api(
        'POST',
        '{Service}',
        OBJECT_CONSTRUCT(
            'Content-Type',
            'application/json'
        ),
        OBJECT_CONSTRUCT(
            'method',
            'getblock',
            'params',
            ARRAY_CONSTRUCT(
                block_hash,
                2
            )
        ),
        'Vault/prod/bitcoin/quicknode'
    ) AS request
FROM
    tbl
ORDER BY
    block_number DESC
