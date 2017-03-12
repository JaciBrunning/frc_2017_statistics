INSERT INTO rankings(team, event, rank, rank_points, 
    match_points, auto_points, 
    rotor_points, touchpad_points, pressure_points, 
    win, loss, tie, played)
VALUES (
    ?,
    (SELECT id FROM events WHERE key == ?),
    ?, ?,
    ?, ?, 
    ?, ?, ?,
    ?, ?, ?, ?
);