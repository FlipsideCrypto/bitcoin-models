{{ config (
    materialized = "view",
    post_hook = fsc_utils.if_data_call_function_v2(
        func = 'streamline.udf_bulk_rest_api_v2',
        target = "{{this.schema}}.{{this.identifier}}",
        params ={ "external_table" :"blocks_hash_v2",
        "sql_limit" :"500",
        "producer_batch_size" :"100",
        "worker_batch_size" :"100",
        "sql_source" :"{{this.identifier}}" }
    )
) }}
-- depends_on: {{ ref('streamline__chainhead') }}
-- depends_on: {{ ref('streamline__blocks') }}
-- depends_on: {{ ref('streamline__complete_blocks_hash') }}
WITH last_3_days AS ({% if var('STREAMLINE_RUN_HISTORY') %}

    SELECT
        0 AS block_number
    {% else %}
    SELECT
        MAX(block_number) - 500 AS block_number --aprox 3 days
    FROM
        {{ ref("streamline__blocks") }}
    {% endif %}),
    tbl AS (
        SELECT
            block_number
        FROM
            {{ ref("streamline__blocks") }}
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
            block_number
        FROM
            {{ ref("streamline__complete_blocks_hash") }}
        WHERE
            block_number >= (
                SELECT
                    block_number
                FROM
                    last_3_days
            )
            AND block_number IS NOT NULL
    )
SELECT
    block_number,
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
            'getblockhash',
            'params',
            ARRAY_CONSTRUCT(
                block_number
            )
        ),
        'Vault/prod/bitcoin/quicknode'
    ) AS request
FROM
    tbl
ORDER BY
    block_number
