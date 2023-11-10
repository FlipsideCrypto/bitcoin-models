{{ config(
    materialized = 'incremental',
    unique_key = 'address',
    tags = ["core", "scheduled_non_core"]
) }}

SELECT
    TO_TIMESTAMP_NTZ(system_created_at) AS system_created_at,
    TO_TIMESTAMP_NTZ(insert_date) AS insert_date,
    blockchain,
    address,
    creator,
    label_type,
    label_subtype,
    address_name,
    project_name
FROM
    {{ ref('bronze__labels') }}
WHERE
    insert_date >= '2023-10-04'

{% if is_incremental() %}
AND insert_date >= (
    SELECT
        MAX(
            insert_date
        )
    FROM
        {{ this }}
)
{% endif %}
