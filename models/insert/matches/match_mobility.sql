INSERT INTO match_team_mobility (
    match_scores, team, mobility
) VALUES (
    (SELECT id FROM match_scores WHERE match == (SELECT id FROM matches WHERE key == ?) AND alliance_color == ?),
    (SELECT id FROM teams WHERE key == ?), ?
)