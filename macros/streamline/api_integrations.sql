{% macro create_aws_bitcoin_api() %}
    {% if target.name == "prod" %}
        {% set sql %}
        CREATE api integration IF NOT EXISTS AWS_BITCOIN_API_PROD api_provider = aws_api_gateway api_aws_role_arn = 'arn:aws:iam::924682671219:role/bitcoin-api-prod-rolesnowflakeudfsAF733095-D1PYK9UQXd8m' api_allowed_prefixes = (
            'https://6fmgkfdhy6.execute-api.us-east-1.amazonaws.com/prod/'
        ) enabled = TRUE;
        {% endset %}
        {% do run_query(sql) %}
    {% else %}
        {% set sql %}
        CREATE api integration IF NOT EXISTS AWS_BITCOIN_API_STG api_provider = aws_api_gateway api_aws_role_arn = 'arn:aws:iam::704693948482:role/bitcoin-api-stg-rolesnowflakeudfsAF733095-Kp1QvE8vqElN' api_allowed_prefixes = (
            'https://zta5i3yyxd.execute-api.us-east-1.amazonaws.com/stg/'
        ) enabled = TRUE;
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
