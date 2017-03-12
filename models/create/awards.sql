CREATE TABLE award_types (
    id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE awards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event INTEGER,
    team INTEGER,
    awardee TEXT,
    award INTEGER,
    
    UNIQUE(event, team, awardee, award),
    FOREIGN KEY(event) REFERENCES events(id),
    FOREIGN KEY(team) REFERENCES teams(id),
    FOREIGN KEY(award) REFERENCES award_names(id)
);