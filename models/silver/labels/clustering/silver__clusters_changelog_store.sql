{{ config(
    materialized = 'incremental',
    unique_key = 'clusters_changelog_store_id',
    incremental_strategy = 'merge',
    merge_exclude_columns = ["inserted_timestamp"],
    tags = ['entity_cluster_0'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION",
    full_refresh = False
) }}

SELECT
    MD5(concat_ws('-', addresses :: STRING, SYSDATE() :: DATE)) AS clusters_changelog_store_id,
    CLUSTERS :: ARRAY AS CLUSTERS,
    addresses :: ARRAY AS addresses,
    change_type :: STRING AS change_type,
    new_cluster_id :: BIGINT AS new_cluster_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS invocation_id
FROM
    {% if var(
            'CLUSTER_BACKFILL',
            False
        ) %}
        {{ target.database }}.bronze.FIX_CLUSTER_ADDITION
    {% else %}
        {{ ref(
            "silver__clusters_changelog"
        ) }}
    {% endif %}
