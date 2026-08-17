with source as (
    select * from {{ source('statcast', 'pitches') }}
),

cleaned as (
    select
        ---------- grain / keys
        try_cast(game_pk as bigint)                         as game_id,
        try_cast(at_bat_number as int)                      as at_bat_number,
        try_cast(pitch_number as int)                       as pitch_number,
        try_cast(batter as bigint)                          as batter_id,
        try_cast(pitcher as bigint)                         as pitcher_id,

        ---------- game context
        try_cast(game_date as date)                         as game_date,
        try_cast(game_year as int)                          as game_year,
        nullif(trim(game_type), '')                         as game_type,
        nullif(trim(home_team), '')                         as home_team_code,
        nullif(trim(away_team), '')                         as away_team_code,
        try_cast(inning as int)                             as inning,
        nullif(trim(inning_topbot), '')                     as inning_half,
        try_cast(outs_when_up as int)                       as outs_when_up,
        try_cast(balls as int)                              as ball_count,
        try_cast(strikes as int)                            as strike_count,

        ---------- runners
        try_cast(on_1b as bigint)                           as runner_on_1b_id,
        try_cast(on_2b as bigint)                           as runner_on_2b_id,
        try_cast(on_3b as bigint)                           as runner_on_3b_id,

        ---------- score
        try_cast(home_score as int)                         as home_score,
        try_cast(away_score as int)                         as away_score,
        try_cast(bat_score as int)                          as batting_team_score,
        try_cast(fld_score as int)                          as fielding_team_score,
        try_cast(post_home_score as int)                    as post_home_score,
        try_cast(post_away_score as int)                    as post_away_score,
        try_cast(post_bat_score as int)                     as post_batting_team_score,
        try_cast(post_fld_score as int)                     as post_fielding_team_score,
        try_cast(home_score_diff as int)                    as home_score_diff,
        try_cast(bat_score_diff as int)                     as batting_score_diff,

        ---------- pitch characteristics
        nullif(trim(pitch_type), '')                        as pitch_type_code,
        nullif(trim(pitch_name), '')                        as pitch_name,
        try_cast(release_speed as decimal(5,1))             as release_speed,
        try_cast(effective_speed as decimal(5,1))           as effective_speed,
        try_cast(release_spin_rate as int)                  as release_spin_rate,
        try_cast(spin_axis as int)                          as spin_axis,
        try_cast(release_extension as decimal(4,1))         as release_extension,
        try_cast(release_pos_x as decimal(6,2))             as release_pos_x,
        try_cast(release_pos_y as decimal(6,2))             as release_pos_y,
        try_cast(release_pos_z as decimal(6,2))             as release_pos_z,
        try_cast(arm_angle as decimal(5,1))                 as arm_angle,

        ---------- pitch movement
        try_cast(pfx_x as decimal(6,2))                     as horizontal_movement,
        try_cast(pfx_z as decimal(6,2))                     as vertical_movement,
        try_cast(api_break_z_with_gravity as decimal(6,2))  as vertical_break_with_gravity,
        try_cast(api_break_x_arm as decimal(6,2))           as horizontal_break_arm_side,
        try_cast(api_break_x_batter_in as decimal(6,2))     as horizontal_break_batter_side,

        ---------- pitch location
        try_cast(plate_x as decimal(6,2))                   as plate_x,
        try_cast(plate_z as decimal(6,2))                   as plate_z,
        try_cast(zone as int)                               as strike_zone_region,
        try_cast(sz_top as decimal(4,2))                    as strike_zone_top,
        try_cast(sz_bot as decimal(4,2))                    as strike_zone_bottom,

        ---------- pitch result
        nullif(trim(type), '')                              as pitch_result_code,
        nullif(trim(description), '')                       as pitch_result_description,
        nullif(trim(events), '')                            as at_bat_event,
        nullif(trim(des), '')                               as play_description,

        ---------- batter / pitcher attributes
        nullif(trim(stand), '')                             as batter_side,
        nullif(trim(p_throws), '')                          as pitcher_hand,
        nullif(trim(player_name), '')                       as pitcher_name,
        try_cast(age_bat as int)                            as batter_age,
        try_cast(age_pit as int)                            as pitcher_age,

        ---------- batted ball
        nullif(trim(bb_type), '')                           as batted_ball_type,
        try_cast(launch_speed as decimal(5,1))              as exit_velocity,
        try_cast(launch_angle as int)                       as launch_angle,
        try_cast(hit_distance_sc as int)                    as hit_distance,
        try_cast(hc_x as decimal(7,2))                      as hit_coord_x,
        try_cast(hc_y as decimal(7,2))                      as hit_coord_y,
        try_cast(hit_location as int)                       as hit_fielder_position,
        try_cast(launch_speed_angle as int)                 as launch_speed_angle_bucket,

        ---------- swing tracking
        try_cast(bat_speed as decimal(5,1))                 as bat_speed,
        try_cast(swing_length as decimal(5,1))              as swing_length,
        try_cast(miss_distance as decimal(5,1))             as miss_distance,
        try_cast(attack_angle as decimal(5,1))              as attack_angle,
        try_cast(attack_direction as decimal(5,1))          as attack_direction,
        try_cast(swing_path_tilt as decimal(5,1))           as swing_path_tilt,
        try_cast(hyper_speed as decimal(5,1))               as hyper_speed,
        try_cast(intercept_ball_minus_batter_pos_x_inches as decimal(5,1))
                                                            as intercept_x_inches,
        try_cast(intercept_ball_minus_batter_pos_y_inches as decimal(5,1))
                                                            as intercept_y_inches,

        ---------- expected stats
        try_cast(estimated_ba_using_speedangle as decimal(5,3))
                                                            as expected_batting_avg,
        try_cast(estimated_woba_using_speedangle as decimal(5,3))
                                                            as expected_woba,
        try_cast(estimated_slg_using_speedangle as decimal(5,3))
                                                            as expected_slugging,

        ---------- value stats
        try_cast(woba_value as decimal(8,3))                as woba_value,
        try_cast(woba_denom as int)                         as woba_denom,
        try_cast(babip_value as int)                        as babip_value,
        try_cast(iso_value as int)                          as iso_value,
        try_cast(delta_run_exp as decimal(8,3))             as delta_run_expectancy,
        try_cast(delta_pitcher_run_exp as decimal(8,3))     as delta_pitcher_run_expectancy,

        ---------- win probability
        try_cast(home_win_exp as decimal(5,3))              as home_win_expectancy,
        try_cast(bat_win_exp as decimal(5,3))               as batting_win_expectancy,
        try_cast(delta_home_win_exp as decimal(8,3))        as delta_home_win_expectancy,

        ---------- game state context
        try_cast(n_thruorder_pitcher as int)                as pitcher_times_through_order,
        try_cast(n_priorpa_thisgame_player_at_bat as int)   as batter_prior_pas_in_game,
        try_cast(pitcher_days_since_prev_game as int)       as pitcher_days_rest,
        try_cast(batter_days_since_prev_game as int)        as batter_days_rest,
        try_cast(pitcher_days_until_next_game as int)       as pitcher_days_until_next,
        try_cast(batter_days_until_next_game as int)        as batter_days_until_next,

        ---------- fielding alignment
        nullif(trim(if_fielding_alignment), '')             as infield_alignment,
        nullif(trim(of_fielding_alignment), '')             as outfield_alignment,

        ---------- fielder IDs
        try_cast(fielder_2 as bigint)                       as catcher_id,
        try_cast(fielder_3 as bigint)                       as first_baseman_id,
        try_cast(fielder_4 as bigint)                       as second_baseman_id,
        try_cast(fielder_5 as bigint)                       as third_baseman_id,
        try_cast(fielder_6 as bigint)                       as shortstop_id,
        try_cast(fielder_7 as bigint)                       as left_fielder_id,
        try_cast(fielder_8 as bigint)                       as center_fielder_id,
        try_cast(fielder_9 as bigint)                       as right_fielder_id,

        ---------- velocity / acceleration vectors
        try_cast(vx0 as decimal(8,3))                       as velocity_x,
        try_cast(vy0 as decimal(8,3))                       as velocity_y,
        try_cast(vz0 as decimal(8,3))                       as velocity_z,
        try_cast(ax as decimal(8,3))                        as acceleration_x,
        try_cast(ay as decimal(8,3))                        as acceleration_y,
        try_cast(az as decimal(8,3))                        as acceleration_z,

        ---------- lineage
        _loaded_at,
        _source_system

    from source
    where game_type = 'R'
)

select * from cleaned