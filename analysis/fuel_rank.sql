WITH rp AS (SELECT round(rankings.rank_points * rankings.played) AS [rp], rankings.team, rankings.event, rankings.id AS rankings FROM rankings),
		bonus_rp AS (
			SELECT sum(match_scores.pressure_bonus_rank_point) as [bonuses], 
			matches.event,
			match_teams.team AS team
			FROM match_scores INNER JOIN match_teams on match_scores.match == match_teams.match, matches ON matches.id == match_scores.match
			GROUP BY match_teams.team, matches.event),
		rank_combo AS (
			SELECT events.key AS [event], rp.rp AS [RP], bonus_rp.bonuses AS [bonus_rp], (rp.rp - bonus_rp.bonuses) AS [rp_no_bonus], rp.team, rankings.rank AS [rank] FROM rp
			INNER JOIN events ON events.id == rp.event
			INNER JOIN bonus_rp ON bonus_rp.event == events.id AND bonus_rp.team == rp.team
			INNER JOIN rankings ON rp.rankings == rankings.id)

SELECT team1.event AS event, 
team1.team AS [Team 1], team1.rank AS [T1_Rank], team1.RP as [T1_RP], team1.bonus_rp AS [T1_Bonus], 
team2.team as [Team 2], team2.rank AS [T2_Rank], team2.RP as [T2_RP], team2.bonus_rp AS [T2_Bonus]
FROM rank_combo AS team1
INNER JOIN rank_combo AS team2 ON team2.event == team1.event
WHERE team2.rank - team1.rank == 1
AND team1.rp_no_bonus < team2.rp_no_bonus
ORDER BY team1.event, team1.rank
