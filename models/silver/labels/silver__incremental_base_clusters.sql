{{ config(
  materialized = 'view',
  tags = ['snowflake', 'cluster', 'labels', 'entity_cluster', 'incremental']
) }}

SELECT
  address_group,
  ARRAY_AGG(address) :: STRING AS address_list
FROM
  {{ ref(
    "silver__full_entity_cluster"
  ) }}
WHERE
  address IN (
    SELECT
      pubkey_script_address
    FROM
      {{ source(
      "bitcoin_core",
      "fact_inputs"
    ) }}
    WHERE
      block_timestamp > (
        SELECT
          MAX(_inserted_timestamp)
        FROM
          {{ ref(
            "silver__full_entity_cluster"
          ) }}
      )
  )
GROUP BY
  address_group