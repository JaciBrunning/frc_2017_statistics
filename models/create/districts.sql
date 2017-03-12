CREATE TABLE districts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT,
    name TEXT,
    
    UNIQUE(key)
);

CREATE TABLE district_teams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team INTEGER,
    district INTEGER,
    
    UNIQUE(team, district),
    FOREIGN KEY(district) REFERENCES districts(id)
);

CREATE TABLE district_event_points (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team INTEGER,
    event INTEGER,
    district INTEGER,
    
    alliance_points INTEGER,
    award_points INTEGER,
    qual_points INTEGER,
    elim_points INTEGER,
    total_points INTEGER,
    
    UNIQUE(team, event, district),
    FOREIGN KEY(district) REFERENCES districts(id)
);

CREATE TABLE district_rankings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team INTEGER,
    district INTEGER,
    
    rank INTEGER,
    points INTEGER,
    rookie_bonus INTEGER,
    
    UNIQUE(team, district),
    FOREIGN KEY(district) REFERENCES districts(id)
);