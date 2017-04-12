SELECT sum(match_scores.total_points) as [Total], matches.key FROM matches
INNER JOIN match_scores ON match_scores.match == matches.id
GROUP BY matches.key
ORDER BY [Total] DESC