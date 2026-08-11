with pitches as (
    select * from {{ ref('int_pitches_enriched') }}
),

at_bats as (
    select
        ---------- grain
        game_id,
        at_bat_number,

        ---------- context (constant across the at-bat)
        game_date,
        game_year,
        batter_id,
        pitcher_id,
        batter_side,
        pitcher_hand,
        home_team_code,
        away_team_code,
        inning,
        inning_half,

        ---------- plate appearance outcome (from final pitch)
        max(at_bat_event)                               as at_bat_event,
        max(batted_ball_type)                           as batted_ball_type,
        max(batted_ball_category)                       as batted_ball_category,

        ---------- pitch counts
        count(*)                                        as pitch_count,
        sum(is_strike)                                  as strike_count,
        sum(is_ball)                                    as ball_count,
        sum(is_swing)                                   as swing_count,
        sum(is_whiff)                                   as whiff_count,
        sum(is_called_strike)                           as called_strike_count,

        ---------- batted ball metrics (from the in-play pitch)
        max(exit_velocity)                              as exit_velocity,
        max(launch_angle)                               as launch_angle,
        max(hit_distance)                               as hit_distance,
        max(bat_speed)                                  as bat_speed,
        max(swing_length)                               as swing_length,

        ---------- expected stats
        max(expected_batting_avg)                       as expected_batting_avg,
        max(expected_woba)                              as expected_woba,
        max(expected_slugging)                          as expected_slugging,

        ---------- outcome flags
        max(is_hit)                                     as is_hit,
        max(is_single)                                  as is_single,
        max(is_double)                                  as is_double,
        max(is_triple)                                  as is_triple,
        max(is_home_run)                                as is_home_run,
        max(is_strikeout)                               as is_strikeout,
        max(is_walk)                                    as is_walk,
        max(is_hit_by_pitch)                            as is_hit_by_pitch,
        max(is_out_in_play)                             as is_out_in_play,
        max(is_barrel)                                  as is_barrel,
        max(is_hard_hit)                                as is_hard_hit,

        ---------- run / win values (sum across all pitches)
        sum(delta_run_expectancy)                       as total_delta_run_expectancy,
        sum(delta_pitcher_run_expectancy)               as total_delta_pitcher_run_expectancy

    from pitches
    group by
        game_id, at_bat_number, game_date, game_year,
        batter_id, pitcher_id, batter_side, pitcher_hand,
        home_team_code, away_team_code, inning, inning_half
)

select * from at_bats