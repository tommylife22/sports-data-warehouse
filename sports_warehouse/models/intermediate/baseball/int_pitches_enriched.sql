with pitches as (
    select * from {{ ref('stg_statcast__pitches') }}
),

enriched as (
    select
        *,

        ---------- pitch result flags
        case
            when pitch_result_code in ('S', 'X') then 1
            else 0
        end                                             as is_strike,

        case
            when pitch_result_code = 'B' then 1
            else 0
        end                                             as is_ball,

        case
            when pitch_result_code = 'X' then 1
            else 0
        end                                             as is_in_play,

        case
            when pitch_result_description in (
                'swinging_strike', 'swinging_strike_blocked',
                'foul_tip', 'missed_bunt'
            ) then 1
            else 0
        end                                             as is_whiff,

        case
            when pitch_result_description like '%swing%'
              or pitch_result_description like '%foul%'
              or pitch_result_description = 'hit_into_play'
              or pitch_result_description like '%bunt%'
            then 1
            else 0
        end                                             as is_swing,

        case
            when pitch_result_description = 'called_strike' then 1
            else 0
        end                                             as is_called_strike,

        ---------- first pitch flag
        case
            when ball_count = 0 and strike_count = 0
              and pitch_result_code in ('S', 'X') then 1
            else 0
        end                                             as is_first_pitch_strike,

        ---------- plate appearance outcome flags (final pitch only)
        case when at_bat_event = 'strikeout' then 1 else 0 end
                                                        as is_strikeout,
        case when at_bat_event = 'walk' then 1 else 0 end
                                                        as is_walk,
        case
            when at_bat_event in ('single', 'double', 'triple', 'home_run')
            then 1 else 0
        end                                             as is_hit,
        case when at_bat_event = 'single' then 1 else 0 end
                                                        as is_single,
        case when at_bat_event = 'double' then 1 else 0 end
                                                        as is_double,
        case when at_bat_event = 'triple' then 1 else 0 end
                                                        as is_triple,
        case when at_bat_event = 'home_run' then 1 else 0 end
                                                        as is_home_run,
        case when at_bat_event = 'hit_by_pitch' then 1 else 0 end
                                                        as is_hit_by_pitch,
        case
            when at_bat_event in (
                'field_out', 'grounded_into_double_play',
                'force_out', 'fielders_choice', 'double_play',
                'fielders_choice_out', 'triple_play',
                'sac_fly', 'sac_bunt'
            ) then 1 else 0
        end                                             as is_out_in_play,

        ---------- at-bat completion flag
        case
            when at_bat_event is not null then 1
            else 0
        end                                             as is_final_pitch_of_pa,

        ---------- batted ball quality flags
        case
            when exit_velocity >= 95
              and launch_angle between 10 and 30
            then 1 else 0
        end                                             as is_barrel,

        case
            when exit_velocity >= 95 then 1
            else 0
        end                                             as is_hard_hit,

        case
            when exit_velocity < 70
              and exit_velocity is not null
            then 1 else 0
        end                                             as is_weak_contact,

        ---------- batted ball categories
        case
            when launch_angle < 10 then 'ground_ball'
            when launch_angle between 10 and 25 then 'line_drive'
            when launch_angle between 25 and 50 then 'fly_ball'
            when launch_angle >= 50 then 'popup'
            else null
        end                                             as batted_ball_category,

        ---------- base state flags
        case
            when runner_on_1b_id is not null
              or runner_on_2b_id is not null
              or runner_on_3b_id is not null
            then 1 else 0
        end                                             as has_runners_on,

        case
            when runner_on_2b_id is not null
              or runner_on_3b_id is not null
            then 1 else 0
        end                                             as has_runner_in_scoring_position,

        case
            when runner_on_1b_id is not null
              and runner_on_2b_id is not null
              and runner_on_3b_id is not null
            then 1 else 0
        end                                             as is_bases_loaded,

        ---------- base-out state code (for RE24 lookups)
        concat(
            case when runner_on_1b_id is not null then '1' else '0' end,
            case when runner_on_2b_id is not null then '1' else '0' end,
            case when runner_on_3b_id is not null then '1' else '0' end,
            '_',
            cast(outs_when_up as varchar)
        )                                               as base_out_state,

        ---------- count state
        concat(
            cast(ball_count as varchar),
            '-',
            cast(strike_count as varchar)
        )                                               as count_string,

        case
            when ball_count = 3 and strike_count = 2 then 1
            else 0
        end                                             as is_full_count,

        case
            when ball_count = 0 and strike_count = 2 then 1
            when ball_count = 1 and strike_count = 2 then 1
            else 0
        end                                             as is_two_strike_count,

        case
            when strike_count = 0 and ball_count >= 2 then 1
            else 0
        end                                             as is_hitters_count,

        ---------- count leverage category
        case
            when ball_count = 3 and strike_count = 2 then 'Full'
            when strike_count >= ball_count then 'Pitcher ahead'
            when ball_count > strike_count then 'Hitter ahead'
            else 'Even'
        end                                             as count_leverage,

        ---------- game context
        batting_team_score - fielding_team_score         as score_diff_batting,

        case
            when batting_team_score > fielding_team_score then 'Leading'
            when batting_team_score < fielding_team_score then 'Trailing'
            else 'Tied'
        end                                             as batting_team_situation,

        case
            when inning >= 7
              and abs(batting_team_score - fielding_team_score) <= 3
            then 1 else 0
        end                                             as is_late_and_close

    from pitches
)

select * from enriched