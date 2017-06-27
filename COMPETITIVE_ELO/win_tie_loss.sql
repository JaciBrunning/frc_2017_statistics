SELECT *, matches.key AS [match_key] FROM events
					INNER JOIN matches ON matches.event = events.id
					INNER JOIN (
						SELECT match_teams.team as [team], t_score.total_points as [team_score], t_score.alliance_color as [alliance], nt_score.total_points as [opp_score], match_teams.match as [match],
							(
								case when (t_score.total_points > nt_score.total_points) then 
									'w' 
								else (
									case when (t_score.total_points = nt_score.total_points) then 
										't' 
									else 
										'l' 
								end) 
							end) as win 
						FROM match_teams
						INNER JOIN match_scores as t_score ON t_score.match == match_teams.match AND t_score.alliance_color = match_teams.alliance_color
						INNER JOIN match_scores as nt_score ON nt_score.match == match_teams.match AND nt_score.alliance_color != match_teams.alliance_color
					) as mat_teams ON mat_teams.match = matches.id
					ORDER BY events.start_date, matches.match_level, matches.match_number, matches.set_number
