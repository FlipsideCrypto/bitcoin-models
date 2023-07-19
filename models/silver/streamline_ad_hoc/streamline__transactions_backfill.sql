{{ config (
    materialized = "view",
    post_hook = if_data_call_function(
        func = "{{this.schema}}.udf_json_rpc(object_construct('sql_source', '{{this.identifier}}', 'external_table', 'transactions', 'exploded_key','[\"result\", \"tx\"]', 'producer_batch_size',100, 'producer_limit_size', 1000000, 'worker_batch_size',10))",
        target = "{{this.schema}}.{{this.identifier}}"
    )
) }}

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
tbl AS (
    SELECT
        VALUE AS block_number
    FROM
        blocks,
        LATERAL FLATTEN(
            input => blist
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
