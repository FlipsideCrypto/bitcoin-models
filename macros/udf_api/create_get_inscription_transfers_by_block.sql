{% macro create_get_inscription_transfers_by_block() %}

{% set livequery %}
CREATE 
OR REPLACE FUNCTION {{ target.database }}.STREAMLINE.GET_INSCRIPTION_TRANSFERS_BY_BLOCK(BLOCK_IDENTIFIER VARCHAR, OFFSET INTEGER)
RETURNS VARIANT
AS
$$
SELECT
    {{ target.database }}.LIVE.UDF_API(
        'GET',
        'https://api.hiro.so/ordinals/v1/inscriptions/transfers?block=' || BLOCK_IDENTIFIER || '&offset=' || OFFSET || '&limit=60',
        OBJECT_CONSTRUCT(
            'x-hiro-api-key', '{x-hiro-api-key}'
        ),
        {},
        'vault/prod/bitcoin/hiro'
    ) as response
$$;
{% endset %}

{% do run_query(livequery) %}

{% endmacro %}

{% macro create_generate_offset_array() %}
{% set query %}
CREATE 
OR REPLACE FUNCTION {{ target.database }}.STREAMLINE.GENERATE_OFFSET_ARRAY(CALLS_REQUIRED INTEGER)
RETURNS ARRAY
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
HANDLER = 'generate_offset_array'
AS
$$
def generate_offset_array(calls_required):
    return [60 * i for i in range(calls_required)]

$$;
{% endset %}
{% do run_query(query) %}
{% endmacro %}

