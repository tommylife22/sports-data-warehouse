with source as (
    select * from {{ source('statcast', 'pitches') }}
),

cleaned as (
    select
        ---------- grain / keys
        cast(game_pk as bigint)                         as game_id,
        cast(at_bat_number as int)                      as at_bat_number,
        cast(pitch_number as int)                       as pitch_number,
        cast(batter as bigint)                          as batter_id,
        cast(pitcher as bigint)                         as pitcher_id,

        ---------- game context
        cast(game_date as date)                         as game_date,
        cast(game_year as int)                          as game_year,
        nullif(trim(game_type), '')                     as game_type,
        nullif(trim(home_team), '')                     as home_team_code,
        nullif(trim(away_team), '')                     as away_team_code,
        cast(inning as int)                             as inning,
        nullif(trim(inning_topbot), '')                 as inning_half,
        cast(outs_when_up as int)                       as outs_when_up,
        cast(balls as int)                              as ball_count,
        cast(strikes as int)                            as strike_count,

        ---------- runners
        cast(on_1b as bigint)                           as runner_on_1b_id,
        cast(on_2b as bigint)                           as runner_on_2b_id,
        cast(on_3b as bigint)                           as runner_on_3b_id,

        ---------- score
        cast(home_score as int)                         as home_score,
        cast(away_score as int)                         as away_score,
        cast(bat_score as int)                          as batting_team_score,
        cast(fld_score as int)                          as fielding_team_score,
        cast(post_home_score as int)                    as post_home_score,
        cast(post_away_score as int)                    as post_away_score,
        cast(post_bat_score as int)                     as post_batting_team_score,
        cast(post_fld_score as int)                     as post_fielding_team_score,
        cast(home_score_diff as int)                    as home_score_diff,
        cast(bat_score_diff as int)                     as batting_score_diff,

        ---------- pitch characteristics
        nullif(trim(pitch_type), '')                    as pitch_type_code,
        nullif(trim(pitch_name), '')                    as pitch_name,
        cast(release_speed as decimal(5,1))             as release_speed,
        cast(effective_speed as decimal(5,1))           as effective_speed,
        cast(release_spin_rate as int)                  as release_spin_rate,
        cast(spin_axis as int)                          as spin_axis,
        cast(release_extension as decimal(4,1))         as release_extension,
        cast(release_pos_x as decimal(6,2))             as release_pos_x,
        cast(release_pos_y as decimal(6,2))             as release_pos_y,
        cast(release_pos_z as decimal(6,2))             as release_pos_z,
        cast(arm_angle as decimal(5,1))                 as arm_angle,

        ---------- pitch movement
        cast(pfx_x as decimal(6,2))                     as horizontal_movement,
        cast(pfx_z as decimal(6,2))                     as vertical_movement,
        cast(api_break_z_with_gravity as decimal(6,2))  as vertical_break_with_gravity,
        cast(api_break_x_arm as decimal(6,2))           as horizontal_break_arm_side,
        cast(api_break_x_batter_in as decimal(6,2))     as horizontal_break_batter_side,

        ---------- pitch location
        cast(plate_x as decimal(6,2))                   as plate_x,
        cast(plate_z as decimal(6,2))                   as plate_z,
        cast(zone as int)                               as strike_zone_region,
        cast(sz_top as decimal(4,2))                    as strike_zone_top,
        cast(sz_bot as decimal(4,2))                    as strike_zone_bottom,

        ---------- pitch result
        nullif(trim(type), '')                          as pitch_result_code,
        nullif(trim(description), '')                   as pitch_result_description,
        nullif(trim(events), '')                        as at_bat_event,
        nullif(trim(des), '')                           as play_description,

        ---------- batter / pitcher attributes
        nullif(trim(stand), '')                         as batter_side,
        nullif(trim(p_throws), '')                      as pitcher_hand,
        nullif(trim(player_name), '')                   as pitcher_name,
        cast(age_bat as int)                            as batter_age,
        cast(age_pit as int)                            as pitcher_age,

        ---------- batted ball
        nullif(trim(bb_type), '')                       as batted_ball_type,
        cast(launch_speed as decimal(5,1))              as exit_velocity,
        cast(launch_angle as int)                       as launch_angle,
        cast(hit_distance_sc as int)                    as hit_distance,
        cast(hc_x as decimal(7,2))                      as hit_coord_x,
        cast(hc_y as decimal(7,2))                      as hit_coord_y,
        cast(hit_location as int)                       as hit_fielder_position,
        cast(launch_speed_angle as int)                 as launch_speed_angle_bucket,

        ---------- swing tracking
        cast(bat_speed as decimal(5,1))                 as bat_speed,
        cast(swing_length as decimal(5,1))              as swing_length,
        cast(miss_distance as decimal(5,1))             as miss_distance,
        cast(attack_angle as decimal(5,1))              as attack_angle,
        cast(attack_direction as decimal(5,1))          as attack_direction,
        cast(swing_path_tilt as decimal(5,1))           as swing_path_tilt,
        cast(hyper_speed as decimal(5,1))               as hyper_speed,
        cast(intercept_ball_minus_batter_pos_x_inches as decimal(5,1))
                                                        as intercept_x_inches,
        cast(intercept_ball_minus_batter_pos_y_inches as decimal(5,1))
                                                        as intercept_y_inches,

        ---------- expected stats
        cast(estimated_ba_using_speedangle as decimal(5,3))
                                                        as expected_batting_avg,
        cast(estimated_woba_using_speedangle as decimal(5,3))
                                                        as expected_woba,
        cast(estimated_slg_using_speedangle as decimal(5,3))
                                                        as expected_slugging,

        ---------- value stats
        cast(woba_value as decimal(8,3))                as woba_value,
        cast(woba_denom as int)                         as woba_denom,
        cast(babip_value as int)                        as babip_value,
        cast(iso_value as int)                          as iso_value,
        cast(delta_run_exp as decimal(8,3))             as delta_run_expectancy,
        cast(delta_pitcher_run_exp as decimal(8,3))     as delta_pitcher_run_expectancy,

        ---------- win probability
        cast(home_win_exp as decimal(5,3))              as home_win_expectancy,
        cast(bat_win_exp as decimal(5,3))               as batting_win_expectancy,
        cast(delta_home_win_exp as decimal(8,3))        as delta_home_win_expectancy,

        ---------- game state context
        cast(n_thruorder_pitcher as int)                as pitcher_times_through_order,
        cast(n_priorpa_thisgame_player_at_bat as int)   as batter_prior_pas_in_game,
        cast(pitcher_days_since_prev_game as int)       as pitcher_days_rest,
        cast(batter_days_since_prev_game as int)        as batter_days_rest,
        cast(pitcher_days_until_next_game as int)       as pitcher_days_until_next,
        cast(batter_days_until_next_game as int)        as batter_days_until_next,

        ---------- fielding alignment
        nullif(trim(if_fielding_alignment), '')         as infield_alignment,
        nullif(trim(of_fielding_alignment), '')         as outfield_alignment,

        ---------- fielder IDs
        cast(fielder_2 as bigint)                       as catcher_id,
        cast(fielder_3 as bigint)                       as first_baseman_id,
        cast(fielder_4 as bigint)                       as second_baseman_id,
        cast(fielder_5 as bigint)                       as third_baseman_id,
        cast(fielder_6 as bigint)                       as shortstop_id,
        cast(fielder_7 as bigint)                       as left_fielder_id,
        cast(fielder_8 as bigint)                       as center_fielder_id,
        cast(fielder_9 as bigint)                       as right_fielder_id,

        ---------- velocity / acceleration vectors
        cast(vx0 as decimal(8,3))                       as velocity_x,
        cast(vy0 as decimal(8,3))                       as velocity_y,
        cast(vz0 as decimal(8,3))                       as velocity_z,
        cast(ax as decimal(8,3))                        as acceleration_x,
        cast(ay as decimal(8,3))                        as acceleration_y,
        cast(az as decimal(8,3))                        as acceleration_z,

        ---------- lineage
        _loaded_at,
        _source_system

    from source
    where game_type = 'R'
)

select * from cleaned