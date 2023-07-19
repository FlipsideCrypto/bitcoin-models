{{ config(
    materialized = 'incremental'
) }}

WITH coingecko AS (

    SELECT
        id,
        recorded_hour,
        OPEN,
        high,
        low,
        CLOSE,
        NULL AS volume,
        NULL AS market_cap,
        'coingecko' AS provider,
        _inserted_timestamp
    FROM
        {{ source(
            'crosschain_silver',
            'hourly_prices_coin_gecko'
        ) }}
    WHERE
        id = 'bitcoin'

{% if is_incremental() %}
AND _inserted_timestamp >= (
    SELECT
        MAX(_inserted_timestamp) _inserted_timestamp
    FROM
        {{ this }}
)
{% endif %}
),
coinmarketcap AS (
    SELECT
        id :: STRING AS id,
        recorded_hour,
        OPEN,
        high,
        low,
        CLOSE,
        volume,
        market_cap,
        'coinmarketcap' AS provider,
        _inserted_timestamp
    FROM
        {{ source(
            'crosschain_silver',
            'hourly_prices_coin_market_cap'
        ) }}
    WHERE
        id = 1

{% if is_incremental() %}
AND _inserted_timestamp >= (
    SELECT
        MAX(_inserted_timestamp) _inserted_timestamp
    FROM
        {{ this }}
)
{% endif %}
)
SELECT
    *
FROM
    coingecko
UNION ALL
SELECT
    *
FROM
    coinmarketcap
