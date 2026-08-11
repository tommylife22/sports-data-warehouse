-- Grain: one row per pitch (game_id + at_bat_number + pitch_number)

select
    {{ dbt_utils.generate_surrogate_key([
        'game_id', 'at_bat_number', 'pitch_number'
    ]) }}                                               as pitch_key,

    ---------- foreign keys
    game_id,
    batter_id,
    pitcher_id,
    pitch_type_code,

    ---------- degenerate dimensions
    game_date,
    at_bat_number,
    pitch_number,
    inning,
    inning_half,
    outs_when_up,
    ball_count,
    strike_count,
    batter_side,
    pitcher_hand,
    count_string,
    count_leverage,
    base_out_state,
    batting_team_situation,

    ---------- measures: pitch characteristics
    release_speed,
    effective_speed,
    release_spin_rate,
    spin_axis,
    release_extension,
    arm_angle,
    horizontal_movement,
    vertical_movement,
    plate_x,
    plate_z,

    ---------- measures: batted ball
    exit_velocity,
    launch_angle,
    hit_distance,
    bat_speed,
    swing_length,

    ---------- measures: expected / value stats
    expected_batting_avg,
    expected_woba,
    expected_slugging,
    woba_value,
    delta_run_expectancy,
    delta_pitcher_run_expectancy,

    ---------- measures: win probability
    home_win_expectancy,
    batting_win_expectancy,
    delta_home_win_expectancy,

    ---------- flags
    is_strike,
    is_ball,
    is_in_play,
    is_whiff,
    is_swing,
    is_called_strike,
    is_first_pitch_strike,
    is_barrel,
    is_hard_hit,
    is_final_pitch_of_pa,
    has_runners_on,
    has_runner_in_scoring_position,
    is_late_and_close

from {{ ref('int_pitches_enriched') }}