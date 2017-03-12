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
triggered_pads AS (
	SELECT match_scores.*, sum(match_touchpads.triggered) as [pads_triggered] FROM match_scores
	INNER JOIN match_touchpads ON match_scores.id == match_touchpads.match_scores
	GROUP BY (match_scores.id)
)

SELECT matches.key as [Match Key], match_scores.alliance_color as [Winning Alliance], win_pads.pads_triggered as [Winning Climbers], lose_pads.pads_triggered as [Losing Climbers], score_differential.points_diff as [Final Points Difference] FROM score_differential
INNER JOIN match_scores ON score_differential.win_score == match_scores.id
INNER JOIN matches ON matches.id == match_scores.match
INNER JOIN triggered_pads AS win_pads ON win_pads.id == score_differential.win_score
INNER JOIN triggered_pads AS lose_pads ON lose_pads.id == score_differential.lose_score
WHERE lose_pads.pads_triggered > win_pads.pads_triggered OR (lose_pads.pads_triggered < win_pads.pads_triggered AND score_differential.points_diff = 0)