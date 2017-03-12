CREATE TABLE teams (
    id INTEGER PRIMARY KEY,
    key TEXT,
    name TEXT,
    nickname TEXT,
    location TEXT,
    region TEXT,
    country TEXT,
    rookie_year INTEGER,

    UNIQUE(id), UNIQUE(key)
);

CREATE TABLE event_teams (
    id INTEGER PRIMARY KEY,
    team INTEGER,
    event INTEGER,
    
    UNIQUE(team, event),
    FOREIGN KEY(team) REFERENCES teams(id),
    FOREIGN KEY(event) REFERENCES events(id)
);