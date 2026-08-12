-- Grain: one row per plate appearance (game_id + at_bat_number)

select
    {{ dbt_utils.generate_surrogate_key([
        'game_id', 'at_bat_number', 'batter_id', 'pitcher_id'
    ]) }}                                               as at_bat_key,

    ---------- foreign keys
    game_id,
    batter_id,
    pitcher_id,

    ---------- degenerate dimensions
    game_date,
    game_year,
    at_bat_number,
    inning,
    inning_half,
    batter_side,
    pitcher_hand,
    home_team_code,
    away_team_code,
    at_bat_event,
    batted_ball_type,
    batted_ball_category,

    ---------- measures: pitch counts
    pitch_count,
    strike_count,
    ball_count,
    swing_count,
    whiff_count,
    called_strike_count,

    ---------- measures: batted ball
    exit_velocity,
    launch_angle,
    hit_distance,
    bat_speed,
    swing_length,

    ---------- measures: expected stats
    expected_batting_avg,
    expected_woba,
    expected_slugging,

    ---------- measures: run / win values
    total_delta_run_expectancy,
    total_delta_pitcher_run_expectancy,

    ---------- flags
    is_hit,
    is_single,
    is_double,
    is_triple,
    is_home_run,
    is_strikeout,
    is_walk,
    is_hit_by_pitch,
    is_out_in_play,
    is_barrel,
    is_hard_hit

from {{ ref('int_at_bats') }}