CREATE TABLE stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team INTEGER,
    event INTEGER,
    opr REAL,
    dpr REAL,
    ccwm REAL,
    
    UNIQUE(team, event),
    FOREIGN KEY(team) REFERENCES teams(id),
    FOREIGN KEY(event) REFERENCES events(id)
);