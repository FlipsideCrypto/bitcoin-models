{{ config(
  severity = 'error',
  tags = ['check_block_fork']
) }}
-- enabled in addition to sequence gap test to ensure we have the correct blocks by hash
WITH silver_blocks AS (

  SELECT
    LAG(block_number) over (
      ORDER BY
        block_number ASC
    ) = (
      block_number - 1
    ) AS likely_block_fork,
    block_number,
    block_timestamp,
    block_hash,
    previous_block_hash AS parent_block_hash_expected,
    LAG(block_number) over (
      ORDER BY
        block_number ASC
    ) AS prior_height_actual,
    LAG(block_hash) over (
      ORDER BY
        block_number ASC
    ) AS prior_hash_actual,
    IFF(
      likely_block_fork,
      livequery.live.udf_api(
        'POST',
        'https://docs-demo.btc.quiknode.pro/',{},{ 'method': 'getblockhash',
        'params': [block_number - 1] }
      ) :data :result :: STRING,
      NULL
    ) AS confirmed_block_hash,
    _partition_by_block_id,
    SYSDATE() AS _test_timestamp
  FROM
    {{ ref('silver__blocks') }}
  WHERE
    block_timestamp :: DATE < CURRENT_DATE
)
SELECT
  *
FROM
  silver_blocks
WHERE
  parent_block_hash_expected <> prior_hash_actual
