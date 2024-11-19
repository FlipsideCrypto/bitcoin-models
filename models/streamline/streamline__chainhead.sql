{{ config (
    materialized = "view",
    tags = ['streamline_view', 'streamline_helper']
) }}

SELECT
    {{ target.database }}.live.udf_api(
        'POST',
        '{Service}',
        OBJECT_CONSTRUCT(
            'Content-Type',
            'application/json',
            'fsc-quantum-state',
            'livequery'
        ),
        OBJECT_CONSTRUCT(
            'jsonrpc',
            '2.0',
            'method',
            'getblockcount'
        ),
        'Vault/prod/bitcoin/quicknode'
    ) :data :result ::INT AS block_number
