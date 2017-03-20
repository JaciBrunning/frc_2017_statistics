SELECT ("http://thebluealliance.com/match/" || matches.key) as [url], match_scores.auto_fuel_high_points, match_scores.auto_fuel_low_points, match_scores.alliance_color FROM matches
INNER JOIN match_scores ON matches.id == match_scores.match
WHERE match_scores.auto_fuel_high_points + match_scores.auto_fuel_low_points >= 40