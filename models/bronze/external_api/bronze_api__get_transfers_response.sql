{{ config(
    'materialized=' view
) }}

{# Columns and exact table name will probably need an update  #}

SELECT
    *
FROM
    {{ source(
        'streamline',
        'hiro_get_transfers_response'
    ) }}
