INSERT INTO district_teams(team, district) 
VALUES(
    ?,
    (SELECT id FROM districts WHERE key == ?)
);