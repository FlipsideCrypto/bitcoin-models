import anyjson as json
import snowflake.snowpark.types as T
import snowflake.snowpark.functions as F

def model(dbt, session):

    dbt.config(
        materialized='incremental',
        incremental_strategy='merge',
        merge_exclude_columns = ['inserted_timestamp'],
        # unique_key='_RES_ID',
        packages=['anyjson', 'snowflake-snowpark-python'],
        tags=["hiro_api"]
    )

    # Constants
    STARTING_HEIGHT = 767430
    BLOCK_RANGE = 1
    HIRO_LIMIT = 60
    VAULT_PATH = 'vault/dev/bitcoin/hiro'

    # API Parameters
    base_url = 'https://api.hiro.so/ordinals/v1/inscriptions/transfers'
    headers = {
        'x-hiro-api-key': '{x-hiro-api-key}'
    }
    payload = {}

    if dbt.is_incremental:
        # Get distinct block_numbers from dbt.this()
        block_numbers = session.sql(f"SELECT DISTINCT block_number FROM {dbt.this}").collect()
        from_block_number = max([row[0] for row in block_numbers])
        to_block_number = from_block_number + BLOCK_RANGE
    
    else:
        from_block_number = STARTING_HEIGHT
        to_block_number = from_block_number + BLOCK_RANGE


    # Load reference table
    transfers_per_block = dbt.ref('silver_ordinals__transfers_per_block').select(
        'block_number',
        'block_hash',
        'transfer_count'
        ).where(
            (F.col('block_number') >= from_block_number) & (F.col('transfer_count') > 0)
        ).order_by(
            'block_number').limit(BLOCK_RANGE).collect()
    
    # Build Result DataFrame with schema: block_number, block_hash, offset, request_id, response, status_code, _request_timestamp
    schema = T.StructType([
        T.StructField('block_number', T.IntegerType()),
        T.StructField('block_hash', T.StringType()),
        T.StructField('offset', T.IntegerType()),
        T.StructField('request_id', T.StringType()),
        T.StructField('response', T.VariantType()),
        # T.StructField('status_code', T.IntegerType()),
        # T.StructField('_request_timestamp', T.TimestampType())
    ])
    
    result_df = session.create_dataframe(
        [],
        schema
    )

    while True:
        offset = 0

        for row in transfers_per_block:
            block_number = int(row[0])
            block_hash = str(row[1])
            transfer_count = int(row[2])

            while offset < transfer_count:
                url = f"{base_url}?block={block_hash}&offset={str(offset)}&limit={str(HIRO_LIMIT)}"

                livequery_sql = f"""
                    SELECT bitcoin.live.udf_api(
                        'GET',
                        '{url}',
                        {headers},
                        {payload},
                        '{VAULT_PATH}'
                    ) as response
                """

                response = session.sql(livequery_sql)
                res_value = json.loads(response.collect()[0][0])

                if res_value is not None:
                    result_df = result_df.union(
                        session.create_dataframe(
                            [
                                [
                                    block_number,
                                    block_hash,
                                    offset,
                                    str(block_number) + '-' + str(offset),
                                    res_value,
                                    # res_value['status_code'],
                                    # F.sysdate()
                                ]
                            ],
                            schema
                        )
                    )

                    offset += HIRO_LIMIT

    return result_df
