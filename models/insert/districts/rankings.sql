INSERT INTO district_rankings(team, district, rank, points, rookie_bonus)
VALUES(
    (SELECT id FROM teams WHERE key == ?),
    (SELECT id FROM districts WHERE key == ?),
    ?, ?, ?
);