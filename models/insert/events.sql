INSERT INTO events(key, code, name, short_name, is_official, type, location, start_date, end_date, district_id)
VALUES (
    ?, ?, ?, ?, ?, 
    (SELECT id FROM event_types WHERE type == ?), 
    ?,
    ?,
    ?, 
    (SELECT IFNULL((SELECT id FROM districts WHERE name == ?), -1))
);