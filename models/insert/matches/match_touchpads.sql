INSERT INTO match_touchpads (
    match_scores, touchpad, triggered
) VALUES (
    (SELECT id FROM match_scores WHERE match == (SELECT id FROM matches WHERE key == ?) AND alliance_color == ?),
    ?, ?
)