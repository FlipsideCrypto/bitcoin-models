{% macro create_udf_get_inscription_transfers_by_block() %}
{# Sends a single call to GET /ordinals/v1/inscriptions/transfers. BLOCK_IDENTIFIER is either height or hash.  #}
{% set livequery %}
CREATE 
OR REPLACE FUNCTION {{ target.database }}.STREAMLINE.UDF_GET_INSCRIPTION_TRANSFERS_BY_BLOCK(BLOCK_IDENTIFIER VARCHAR, OFFSET INTEGER)
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


{% macro create_udf_generate_offset_array() %}
{# Helper function for creating input data in Ordinals Transfers calls. 
Takes total call input and generates array of offsets with max page of 60 responses #}
{% set query %}
CREATE 
OR REPLACE FUNCTION {{ target.database }}.STREAMLINE.UDF_GENERATE_OFFSET_ARRAY(CALLS_REQUIRED INTEGER)
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


{% macro create_sp_get_inscription_transfers_by_block() %}
{# Procedure that calls UDF_GET_INSCRIPTION_TRANSFERS_BY_BLOCK, checks status_code and returns a valid response. #}
{% set query %}
CREATE OR REPLACE PROCEDURE {{ target.database }}.STREAMLINE.SP_GET_INSCRIPTION_TRANSFERS_BY_BLOCK(BLOCK_IDENTIFIER VARCHAR, OFFSET INTEGER)
returns variant
language python
runtime_version=3.11
packages=('snowflake-snowpark-python')
handler='main'
as
$$
import json
import snowflake.snowpark as snowpark
import time

def main(session: snowpark.Session, block_identifier: str, offset: int):
    max_attempts = 3
    attempts = 0
    while attempts < max_attempts:

        query = f"""
            SELECT
                {{ target.database }}.STREAMLINE.UDF_GET_INSCRIPTION_TRANSFERS_BY_BLOCK({block_identifier}, {offset}) as response
    
        """
    
        response_df = session.sql(query)
        res = json.loads(response_df.collect()[0][0])
        
        attempts += 1
        
        if res['status_code'] == 200:
            return res
        elif res['status_code'] == 429:
            retry_after = int(res['headers']['Retry-After'])
            print(f"Rate limit hit, sleeping for {retry_after}s")
            time.sleep(retry_after)
        elif attempts == max_attempts:
            # If max attempts is reached, log response and move on
            return res

$$;
{% endset %}
{% do run_query(query) %}
{% endmacro %}


{% macro create_sp_get_inscription_transfers() %}
{% set create_table %}
CREATE SCHEMA IF NOT EXISTS {{ target.database }}.BRONZE_API;
CREATE TABLE IF NOT EXISTS {{ target.database }}.BRONZE_API.GET_TRANSFERS_RESPONSE(
    block_number INT,
    block_hash STRING,
    offset INT,
    response VARIANT,
    _inserted_timestamp TIMESTAMP_NTZ
);
{% endset %}

{% set create_procedure %}
CREATE 
    OR REPLACE PROCEDURE bitcoin_dev.STREAMLINE.SP_GET_INSCRIPTION_TRANSFERS()
RETURNS INTEGER
LANGUAGE SQL
AS
$$
DECLARE 
    res RESULTSET DEFAULT (select block_number::VARCHAR as block_number, block_hash, offset from bitcoin_dev.silver_ordinals.blocks_needed);
    cur CURSOR FOR res;
    sp_res VARIANT;
    counter INTEGER DEFAULT 0;
BEGIN
    FOR row_variable in cur DO
        let block_number VARCHAR := row_variable.block_number;
        let block_hash VARCHAR  := row_variable.block_hash;
        let offset INTEGER := row_variable.offset;
        
        CALL bitcoin_dev.STREAMLINE.SP_GET_INSCRIPTION_TRANSFERS_BY_BLOCK(:block_number, :offset) INTO sp_res;

        -- if trying to directly insert :sp_res, snowflake tries to wrap PARSE_JSON() which is not allowed in an insert statement
        -- create temporary table to avoid that error and log as variant instead of varchar
        CREATE OR REPLACE TEMPORARY TABLE RES_INT (
            block_number integer,
            block_hash varchar,
            offset integer,
            response variant,
            _inserted_timestamp timestamp_ntz
        ) as 
        select
            :block_number as block_number,
            :block_hash as block_hash,
            :offset as offset,
            :sp_res as response,
            sysdate() as _inserted_timestamp;
        
        INSERT INTO bitcoin_dev.BRONZE_API.GET_TRANSFERS_RESPONSE(
                block_number,
                block_hash,
                offset,
                response,
                _inserted_timestamp
            ) select * from res_int;

            counter := counter + 1;
    END FOR;
    
    RETURN counter;
END;
$$;
{% endset %}

{% do run_query(create_table) %}
{% do run_query(create_procedure) %}


{% endmacro %}
