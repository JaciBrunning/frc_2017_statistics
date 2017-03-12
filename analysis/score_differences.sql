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