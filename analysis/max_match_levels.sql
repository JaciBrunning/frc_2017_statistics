WITH max_match_levels AS (
	SELECT MAX(match_levels.id) as [level], match_levels.key AS [key], teams.id AS [team], events.id AS [event] FROM teams
	INNER JOIN match_teams ON match_teams.team == teams.id
	INNER JOIN matches ON match_teams.match == matches.id
	INNER JOIN match_levels ON match_levels.id == matches.match_level
	INNER JOIN events ON matches.event == events.id
	GROUP BY teams.id, events.id ORDER BY teams.id ASC
), level_ranks AS (
	SELECT max_match_levels.key AS [match_level], max_match_levels.team AS [team], rankings.rank FROM max_match_levels
	INNER JOIN rankings ON rankings.event = max_match_levels.event AND rankings.team = max_match_levels.team
	WHERE max_match_levels.key = "f"
)

SELECT rank, (Count(rank) *100 / (SELECT Count(*) FROM level_ranks) || "%") as [%] FROM level_ranks
GROUP BY rank