{{ config (
    materialized = "view",
    post_hook = if_data_call_function(
        func = "{{this.schema}}.udf_json_rpc(object_construct('sql_source', '{{this.identifier}}', 'external_table', 'transactions', 'exploded_key','[\"result\", \"tx\"]', 'producer_batch_size',100, 'producer_limit_size', 1000000, 'worker_batch_size',10))",
        target = "{{this.schema}}.{{this.identifier}}"
    )
) }}
-- todo parameterize with cli input
WITH blocks AS (

    SELECT
        ARRAY_CONSTRUCT(
            91842,
            91880,
            798601,
            798685,
            798921
        ) AS blist
),
block_list AS (
    SELECT
        VALUE AS block_number
    FROM
        blocks,
        LATERAL FLATTEN(
            input => blist
        )
),
tbl AS (
    SELECT
        block_number,
        DATA :result :: STRING AS block_hash
    FROM
        {{ ref("bronze__streamline_blocks_hash") }}
    WHERE
        block_number IN (
            SELECT
                block_number
            FROM
                block_list
        )
)
SELECT
    block_number,
    'getblock' AS method,
    CONCAT(
        block_hash,
        '_-_',
        '2'
    ) AS params
FROM
    tbl
