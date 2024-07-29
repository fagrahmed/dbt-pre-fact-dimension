

{{
    config(
        materialized="incremental",
        unique_key= ["hash_column"],
        on_schema_change='append_new_columns',
        incremental_strategy = 'merge'
    )
}}

{% set table_exists_query = "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'dbt-dimensions' AND table_name = 'profiles_dimension')" %}
{% set table_exists_result = run_query(table_exists_query) %}
{% set table_exists = table_exists_result.rows[0][0] if table_exists_result and table_exists_result.rows else False %}

-- Ensure dependencies are clearly defined for dbt
{% set _ = ref('profiles_stg_update') %}
{% set _ = ref('profiles_stg_exp') %}
{% set _ = ref('profiles_stg_new') %}
{% set _ = ref('profiles_stg') %}


SELECT
    id,
    operation,
    currentflag,
    expdate,
    walletprofileid,
    partnerid,
    hash_column,
    profile_createdat_local,
    profile_modifiedat_local,
    profile_deletedat_local,
    profile_type,
    partner_name_en,
    partner_name_ar,
    partner_isactive,
    partner_createdat_local,
    partner_modifiedat_local,
    partner_deletedat_local,
    utc,
    loaddate

FROM {{ ref('profiles_stg_update') }} 

UNION ALL

SELECT
    id,
    operation,
    currentflag,
    expdate,
    walletprofileid,
    partnerid,
    hash_column,
    profile_createdat_local,
    profile_modifiedat_local,
    profile_deletedat_local,
    profile_type,
    partner_name_en,
    partner_name_ar,
    partner_isactive,
    partner_createdat_local,
    partner_modifiedat_local,
    partner_deletedat_local,
    utc,
    loaddate

FROM {{ ref('profiles_stg_exp') }} 


UNION ALL

SELECT

    id,
    operation,
    currentflag,
    expdate,
    walletprofileid,
    partnerid,
    hash_column,
    profile_createdat_local,
    profile_modifiedat_local,
    profile_deletedat_local,
    profile_type,
    partner_name_en,
    partner_name_ar,
    partner_isactive,
    partner_createdat_local,
    partner_modifiedat_local,
    partner_deletedat_local,
    utc,
    loaddate
    
FROM {{ ref('profiles_stg_new') }}