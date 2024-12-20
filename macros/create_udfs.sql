{% macro create_udfs() %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% set sql %}
        CREATE schema if NOT EXISTS silver;
{{ create_js_hex_to_int() }};
{{ create_udf_hex_to_int(
            schema = "public"
        ) }}
        {{ create_udf_decode_hex_to_string() }}
        {{ create_udtf_get_base_table(
            schema = "streamline"
        ) }}
        {{ create_udf_get_chainhead() }}
        {{ create_udf_json_rpc() }}
        {{ create_udf_bulk_rest_api_v2() }}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
