-- Grain: one row per MLBAM player ID

with batters as (
    select
        batter_id                                       as player_id,
        max(batter_side)                                as bat_side
    from {{ ref('stg_statcast__pitches') }}
    where batter_id is not null
    group by batter_id
),

pitchers as (
    select
        pitcher_id                                      as player_id,
        max(pitcher_name)                               as player_name,
        max(pitcher_hand)                               as throw_hand
    from {{ ref('stg_statcast__pitches') }}
    where pitcher_id is not null
    group by pitcher_id
),

combined as (
    select
        coalesce(b.player_id, p.player_id)              as player_id,
        p.player_name,
        b.bat_side,
        p.throw_hand
    from batters b
    full outer join pitchers p
        on b.player_id = p.player_id
)

select * from combined