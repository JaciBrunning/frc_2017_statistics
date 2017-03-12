INSERT INTO alliances(num, event) 
VALUES (
    ?,
    (SELECT id FROM events WHERE code == ?)
);