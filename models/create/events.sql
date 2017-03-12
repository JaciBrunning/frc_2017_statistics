CREATE TABLE event_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT
);

INSERT INTO event_types(type) VALUES ('Regional');
INSERT INTO event_types(type) VALUES ('District');
INSERT INTO event_types(type) VALUES ('District Championship');
INSERT INTO event_types(type) VALUES ('Championship Division');
INSERT INTO event_types(type) VALUES ('Championship Finals');
INSERT INTO event_types(type) VALUES ('Offseason');
INSERT INTO event_types(type) VALUES ('Preseason');

CREATE TABLE events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT,
    code TEXT,
    name TEXT,
    short_name TEXT,
    
    is_official INTEGER,
    type INTEGER,
    
    location TEXT,
    start_date DATE,
    end_date DATE,
    
    district_id INTEGER,
    UNIQUE(key), UNIQUE(code)
    FOREIGN KEY(type) REFERENCES event_types(type)
);