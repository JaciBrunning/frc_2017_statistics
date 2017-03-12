INSERT INTO stats(team, event, opr, dpr, ccwm)
VALUES (
    ?,
    (SELECT id FROM events WHERE key == ?),
    ?, ?, ?
);