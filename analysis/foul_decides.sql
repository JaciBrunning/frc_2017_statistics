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
foul_points AS (
	SELECT 
		(match_scores.total_points - match_scores.foul_points) as [no_foul_score],
		match_scores.*
	FROM match_scores
)

SELECT matches.key, winner.total_points as [winner_raw], loser.total_points as [loser_raw], winner_nofoul.no_foul_score as [winner_nofoul], loser_nofoul.no_foul_score as [loser_nofoul], winner.alliance_color
FROM score_differential
INNER JOIN match_scores AS winner ON winner.id == score_differential.win_score
INNER JOIN match_scores AS loser ON loser.id == score_differential.lose_score
INNER JOIN foul_points AS winner_nofoul ON winner_nofoul.id == winner.id
INNER JOIN foul_points AS loser_nofoul ON loser_nofoul.id == loser.id
INNER JOIN matches ON winner.match == matches.id
<SQL>
WHERE (loser_nofoul >= winner_nofoul OR (loser_nofoul <= winner_nofoul AND score_differential.points_diff == 0)) AND NOT (winner_raw == loser_raw AND winner_nofoul == loser_nofoul)
<WHERE>