{{ config(
    materialized='incremental',
    unique_key= ['walletprofileid', 'profile_type'],
    depends_on=['profiles_stg'],
    on_schema_change='append_new_columns',
    pre_hook=[
        "{% if target.schema == 'dbt-dimensions' and source('dbt-dimensions', 'profiles_stg_new') is not none %}TRUNCATE TABLE {{ source('dbt-dimensions', 'profiles_stg_new') }};{% endif %}"
    ]
)}}

{% set table_exists_query = "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'dbt-dimensions' AND table_name = 'profiles_dimension')" %}
{% set table_exists_result = run_query(table_exists_query) %}
{% set table_exists = table_exists_result.rows[0][0] if table_exists_result and table_exists_result.rows else False %}

{% set stg_table_exists_query = "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'dbt-dimensions' AND table_name = 'profiles_stg')" %}
{% set stg_table_exists_result = run_query(stg_table_exists_query) %}
{% set stg_table_exists =stg_table_exists_result.rows[0][0] if stg_table_exists_result and stg_table_exists_result.rows else False %}

{% if table_exists %}

SELECT
    stg.id,
    stg.operation,
    stg.currentflag,
    stg.expdate,
    stg.walletprofileid,
    stg.partnerid,
    stg.hash_column,
    stg.profile_createdat_local,
    stg.profile_modifiedat_local,
    stg.profile_deletedat_local,
    stg.profile_type,
    stg.partner_name_en,
    stg.partner_name_ar,
    stg.partner_isactive,
    stg.partner_createdat_local,
    stg.partner_modifiedat_local,
    stg.partner_deletedat_local,
    stg.utc,
    stg.loaddate

FROM {{ source('dbt-dimensions', 'profiles_stg') }} stg
LEFT JOIN {{ source('dbt-dimensions', 'profiles_dimension') }} dim ON stg.walletprofileid = dim.walletprofileid AND stg.profile_type = dim.profile_type
WHERE dim.walletprofileid IS NULL OR (dim.hash_column != stg.hash_column AND dim.currentflag = true)

{% else %}
-- dimension doesnt exists so all is new

SELECT
    stg.id,
    stg.operation,
    stg.currentflag,
    stg.expdate,
    stg.walletprofileid,
    stg.partnerid,
    stg.hash_column,
    stg.profile_createdat_local,
    stg.profile_modifiedat_local,
    stg.profile_deletedat_local,
    stg.profile_type,
    stg.partner_name_en,
    stg.partner_name_ar,
    stg.partner_isactive,
    stg.partner_createdat_local,
    stg.partner_modifiedat_local,
    stg.partner_deletedat_local,
    stg.utc,
    stg.loaddate

FROM {{ source('dbt-dimensions', 'profiles_stg') }} stg

{% endif %}