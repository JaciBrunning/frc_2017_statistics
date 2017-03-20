WITH score_differential AS (
	SELECT 
		winner.win_score,
		match_scores.id as [lose_score],
		abs(winner.winning_points-match_scores.total_points) AS [points_diff]
	FROM (
		SELECT 
			match_scores.alliance_color as [winning_alliance], 
			max(match_scores.total_points) as [winning_points], 
			match_scores.id as [win_score],
			match_scores.match 
		FROM match_scores 
		GROUP BY match_scores.match
	) AS winner
	INNER JOIN match_scores ON match_scores.match == winner.match AND match_scores.alliance_color != winner.winning_alliance
),
fuel_points AS (
	SELECT 
		(match_scores.total_points - match_scores.auto_fuel_points - match_scores.teleop_fuel_points) as [no_fuel_score],
		match_scores.*
	FROM match_scores
)

SELECT matches.key, winner.total_points as [winner_raw], loser.total_points as [loser_raw], winner_nofuel.no_fuel_score as [winner_nofuel], loser_nofuel.no_fuel_score as [loser_nofuel], winner.alliance_color
FROM score_differential
INNER JOIN match_scores AS winner ON winner.id == score_differential.win_score
INNER JOIN match_scores AS loser ON loser.id == score_differential.lose_score
INNER JOIN fuel_points AS winner_nofuel ON winner_nofuel.id == winner.id
INNER JOIN fuel_points AS loser_nofuel ON loser_nofuel.id == loser.id
INNER JOIN matches ON winner.match == matches.id
<SQL>
WHERE (loser_nofuel >= winner_nofuel OR (loser_nofuel <= winner_nofuel AND score_differential.points_diff == 0)) AND NOT (winner_raw == loser_raw AND winner_nofuel == loser_nofuel)
<WHERE>