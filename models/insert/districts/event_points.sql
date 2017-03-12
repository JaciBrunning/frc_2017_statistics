INSERT INTO district_event_points(team, event, district, alliance_points, 
award_points, qual_points, elim_points, total_points)
VALUES (
    (SELECT id FROM teams WHERE key == ?),
    (SELECT id FROM events WHERE key == ?),
    (SELECT id FROM districts WHERE key == ?),
    ?, ?, ?, ?, ?
);