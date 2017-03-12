INSERT INTO alliance_picks(alliance, pick, team) 
VALUES(
    (SELECT id FROM alliances WHERE num == ? 
    AND event == (SELECT id FROM events WHERE code == ?)), 
    ?, 
    (SELECT id FROM teams WHERE key == ?)
);