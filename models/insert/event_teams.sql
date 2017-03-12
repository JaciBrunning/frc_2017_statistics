INSERT INTO event_teams(team, event)
VALUES (
    ?,
    (SELECT id FROM events WHERE key == ?)
);