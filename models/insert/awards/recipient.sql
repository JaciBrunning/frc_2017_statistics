INSERT INTO awards(event, team, awardee, award)
VALUES (
    (SELECT id FROM events WHERE key == ?),
    ?, ?, ?
);