INSERT INTO match_teams(match, alliance_color, alliance_station, team)
VALUES (
    (SELECT id FROM matches WHERE key == ?),
    ?, ?,
    (SELECT id FROM teams WHERE key == ?)
);