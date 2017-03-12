CREATE TABLE rankings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team INTEGER,
    event INTEGER,
    
    rank INTEGER,
    rank_points REAL,
    match_points REAL,
    auto_points REAL,
    rotor_points REAL,
    touchpad_points REAL,
    pressure_points REAL,
    win INTEGER, loss INTEGER, tie INTEGER,
    played INTEGER,
    
    UNIQUE(team, event),
    FOREIGN KEY(team) REFERENCES teams(id),
    FOREIGN KEY(event) REFERENCES events(id)
);