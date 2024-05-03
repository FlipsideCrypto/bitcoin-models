{% macro get_transfers() %}

{% set query %}
CALL {{ target.database }}.STREAMLINE.SP_GET_INSCRIPTION_TRANSFERS();
{% endset %}
{% do run_query(query) %}

{% endmacro %}
