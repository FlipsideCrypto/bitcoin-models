{% macro create_udf_get_chainhead() %}
    {% if target.name == "prod" %}
        CREATE OR REPLACE EXTERNAL FUNCTION streamline.udf_get_chainhead() returns variant api_integration = aws_bitcoin_api AS 
            'https://xgp8ztpp0b.execute-api.us-east-1.amazonaws.com/prod/get_chainhead'
    {% else %}
        CREATE OR REPLACE EXTERNAL FUNCTION streamline.udf_get_chainhead() returns variant api_integration = aws_bitcoin_dev_api AS 
            'https://f81vesdos6.execute-api.us-east-1.amazonaws.com/dev/get_chainhead'  
    {%- endif %};
{% endmacro %}

{% macro create_udf_json_rpc() %}
    {% if target.name == "prod" %}
        CREATE OR REPLACE EXTERNAL FUNCTION streamline.udf_json_rpc(
            json OBJECT
        ) returns ARRAY api_integration = aws_bitcoin_api AS 
            'https://xgp8ztpp0b.execute-api.us-east-1.amazonaws.com/prod/bulk_get_json_rpc'
    {% else %}
        CREATE OR REPLACE EXTERNAL FUNCTION streamline.udf_json_rpc(
            json OBJECT
        ) returns ARRAY api_integration = aws_bitcoin_dev_api AS 
            'https://f81vesdos6.execute-api.us-east-1.amazonaws.com/dev/bulk_get_json_rpc'
    {%- endif %};
{% endmacro %}

{% macro create_udf_bulk_rest_api_v2() %}
    CREATE
    OR REPLACE EXTERNAL FUNCTION streamline.udf_bulk_rest_api_v2(
        json OBJECT
    ) returns ARRAY api_integration = 
    {% if target.name == "prod" %}
        AWS_BITCOIN_API_PROD_V2 AS 'https://6fmgkfdhy6.execute-api.us-east-1.amazonaws.com/prod/udf_bulk_rest_api'
    {% else %}
        AWS_BITCOIN_API_STG_V2 AS 'https://zta5i3yyxd.execute-api.us-east-1.amazonaws.com/stg/udf_bulk_rest_api'
    {%- endif %};
{% endmacro %}
