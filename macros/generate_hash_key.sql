{% macro generate_hash_key(columns, alias='hk') %}
    SHA2(
        CONCAT_WS('||',
            {% for col in columns %}
                UPPER(TRIM(COALESCE(CAST({{ col }} AS VARCHAR), '^^')))
                {%- if not loop.last %},{% endif %}
            {% endfor %}
        ),
        256
    ) AS {{ alias }}
{% endmacro %}