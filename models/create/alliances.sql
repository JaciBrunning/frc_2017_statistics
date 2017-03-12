CREATE TABLE alliances (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    num INTEGER,
    event INTEGER,
    
    UNIQUE(num, event)
    FOREIGN KEY(event) REFERENCES events(id)
);

CREATE TABLE alliance_picks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alliance INTEGER,
    pick INTEGER,
    team INTEGER,
    
    UNIQUE(alliance, pick)
    FOREIGN KEY(alliance) REFERENCES alliances(id),
    FOREIGN KEY(team) REFERENCES teams(id)
);