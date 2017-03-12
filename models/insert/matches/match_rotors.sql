INSERT INTO match_rotors (
    match_scores, rotor, engaged, auto
) VALUES (
    (SELECT id FROM match_scores WHERE match == (SELECT id FROM matches WHERE key == ?) AND alliance_color == ?),
    ?, ?, ?
)