INSERT INTO matches(key, event, match_level, match_number, set_number) 
VALUES (
    ?,
    (SELECT id FROM events WHERE code == ?),
    (SELECT id FROM match_levels WHERE key == ?),
    ?, ?
);