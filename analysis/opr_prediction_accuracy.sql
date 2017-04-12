WITH red AS (SELECT * FROM match_scores WHERE match_scores.alliance_color = "red"),
		blu AS (SELECT * FROM match_scores WHERE match_scores.alliance_color = "blue"),
		red_teams AS (SELECT * FROM match_teams WHERE match_teams.alliance_color = "red"),
		blu_teams AS (SELECT * FROM match_teams WHERE match_teams.alliance_color = "blue"),
		outcomes AS (
			SELECT matches.key as [Match], red.total_points as [Red Score], sum(red_stats.opr)/3 as [Red Predicted], blu.total_points as [Blue Score], sum(blu_stats.opr)/3 as [Blue Predicted] FROM matches
			INNER JOIN red ON red.match = matches.id
			INNER JOIN red_teams ON red_teams.match = matches.id
			INNER JOIN stats AS red_stats ON red_stats.event = matches.event AND red_stats.team = red_teams.team
			INNER JOIN blu ON blu.match = matches.id
			INNER JOIN blu_teams ON blu_teams.match = matches.id
			INNER JOIN stats AS blu_stats ON blu_stats.event = matches.event AND blu_stats.team = blu_teams.team
			GROUP BY matches.id
		),
		winners AS (
			SELECT [Match], ([Red Score]-[Blue Score] > 0) AS [red_winner], ([Red Predicted] - [Blue Predicted] > 0) as [red_predicted_winner], abs([Red Score]-[Blue Score]) as [score_delta], abs([Red Predicted] - [Blue Predicted]) as [prediction_delta] FROM outcomes
			INNER JOIN matches ON matches.key = [Match]
			INNER JOIN match_levels ON match_levels.id = matches.match_level
			WHERE match_levels.key != "qm"
		)

SELECT (1.0*(SELECT Count(*) FROM winners WHERE winners.red_winner = winners.red_predicted_winner) / (SELECT Count(*) FROM winners)*100) AS opr_prediction_accuracy, (SELECT avg(MAX(winners.score_delta, winners.prediction_delta) - MIN(winners.score_delta, winners.prediction_delta)) FROM winners) as [Avg. Prediction Offset]
