CREATE TABLE match_levels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT,
    name TEXT,
    short_name TEXT
);

INSERT INTO match_levels(key, name, short_name) VALUES ('qm', "Qualifications", "Quals");
INSERT INTO match_levels(key, name, short_name) VALUES ('ef', "Octofinals", "Eighths");
INSERT INTO match_levels(key, name, short_name) VALUES ('qf', "Quarterfinals", "Quarters");
INSERT INTO match_levels(key, name, short_name) VALUES ('sf', "Semifinals", "Semis");
INSERT INTO match_levels(key, name, short_name) VALUES ('f', "Finals", "Finals");

CREATE TABLE matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT,
    event INTEGER,
    match_level INTEGER,
    match_number INTEGER,
    set_number INTEGER,
    
    UNIQUE(key, event),
    FOREIGN KEY(match_level) REFERENCES match_levels(id),
    FOREIGN KEY(event) REFERENCES events(id)
);

CREATE TABLE match_teams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match INTEGER,
    alliance_color TEXT,
    alliance_station INTEGER,
    team INTEGER,
    
    UNIQUE(match, alliance_color, team),
    FOREIGN KEY(match) REFERENCES matches(id),
    FOREIGN KEY(team) REFERENCES teams(id)
);

CREATE TABLE match_scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match INTEGER,
    alliance_color TEXT,
    
    teleop_points INTEGER,
    teleop_rotor_points INTEGER,
    teleop_fuel_high INTEGER,
    teleop_fuel_high_points INTEGER,
    teleop_fuel_low INTEGER,
    teleop_fuel_low_points INTEGER,
    teleop_fuel_points INTEGER,
    teleop_takeoff_points INTEGER,

    auto_points INTEGER,
    auto_rotor_points INTEGER,
    auto_fuel_high INTEGER,
    auto_fuel_high_points INTEGER,
    auto_fuel_low INTEGER,
    auto_fuel_low_points INTEGER,
    auto_fuel_points INTEGER,
    auto_mobility_points INTEGER,

    rotor_bonus_points INTEGER,
    rotor_bonus_rank_point INTEGER,
    pressure_bonus_points INTEGER,
    pressure_bonus_rank_point INTEGER,

    foul_points INTEGER,
    foul_count INTEGER,
    tech_foul_count INTEGER,

    total_points INTEGER,
    adjust_points INTEGER,
    
    UNIQUE(match, alliance_color),
    FOREIGN KEY(match) REFERENCES matches(id)
);

CREATE TABLE match_team_mobility (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match_scores INTEGER,
    team INTEGER,

    mobility INTEGER,

    UNIQUE(match_scores, team),
    FOREIGN KEY(match_scores) REFERENCES match_scores(id),
    FOREIGN KEY(team) REFERENCES teams(id)
);

CREATE TABLE match_touchpads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match_scores INTEGER,
    touchpad INTEGER,

    triggered INTEGER,
    
    UNIQUE(match_scores, touchpad),
    FOREIGN KEY(match_scores) REFERENCES match_scores(id)
);

CREATE TABLE match_rotors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match_scores INTEGER,
    rotor INTEGER,

    engaged INTEGER,
    auto INTEGER,

    UNIQUE(match_scores, rotor),
    FOREIGN KEY(match_scores) REFERENCES match_scores(id)
);