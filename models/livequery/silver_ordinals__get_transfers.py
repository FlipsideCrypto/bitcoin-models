import snowflake.snowpark.types as T
import snowflake.snowpark.functions as F

def model(dbt, session):

    dbt.config(
        materialized='incremental',
        incremental_strategy='merge',
        merge_exclude_columns = ['inserted_timestamp'],
        # unique_key='_RES_ID',
        packages=['snowflake-snowpark-python'],
        tags=["hiro_api"]
    )

    # Constants
    STARTING_HEIGHT = 767430
    BATCH_SIZE = 1
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
        to_block_number = from_block_number + BATCH_SIZE
    
    else:
        from_block_number = STARTING_HEIGHT
        to_block_number = from_block_number + BATCH_SIZE


    transfers_per_block = dbt.ref('silver_ordinals__transfers_per_block').select(
        'block_number',
        'block_hash',
        'transfer_count'
        ).where(
            (F.col('block_number') >= from_block_number) & (F.col('transfer_count') > 0)
        ).order_by(
            'block_number').limit(BATCH_SIZE).collect()
    
    while True:
        offset = 0

        for row in transfers_per_block:
            block_number = row[0]
            block_hash = row[1]
            transfer_count = row[2]

            while offset < transfer_count:
                url = f"{base_url}?block={block_hash}&offset={offset}&limit={HIRO_LIMIT}"

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
                res_value = response.collect()

                return response



    return False
