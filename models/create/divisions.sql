CREATE TABLE division_teams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    champ_name TEXT,
    division_name TEXT,
    team INTEGER,

    UNIQUE(division_name, champ_name, team),
    FOREIGN KEY(team) REFERENCES teams(id)
);