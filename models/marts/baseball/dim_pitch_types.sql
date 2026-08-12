-- Grain: one row per pitch type code

with distinct_types as (
    select
        pitch_type_code,
        max(pitch_name)                                 as pitch_name
    from {{ ref('stg_statcast__pitches') }}
    where pitch_type_code is not null
    group by pitch_type_code
)

select
    pitch_type_code,
    pitch_name,
    case pitch_type_code
        when 'FF' then 'Fastball'
        when 'SI' then 'Fastball'
        when 'FC' then 'Fastball'
        when 'SL' then 'Breaking'
        when 'CU' then 'Breaking'
        when 'KC' then 'Breaking'
        when 'SV' then 'Breaking'
        when 'ST' then 'Breaking'
        when 'CH' then 'Offspeed'
        when 'FS' then 'Offspeed'
        when 'FO' then 'Offspeed'
        when 'SC' then 'Offspeed'
        when 'KN' then 'Offspeed'
        else 'Other'
    end                                                 as pitch_category
from distinct_types