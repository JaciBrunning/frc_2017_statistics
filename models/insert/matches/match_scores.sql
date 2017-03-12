INSERT INTO match_scores (
    match, alliance_color,
    teleop_points, teleop_rotor_points, teleop_fuel_high, teleop_fuel_high_points, teleop_fuel_low, teleop_fuel_low_points, teleop_fuel_points, teleop_takeoff_points,
    auto_points, auto_rotor_points, auto_fuel_high, auto_fuel_high_points, auto_fuel_low, auto_fuel_low_points, auto_fuel_points, auto_mobility_points,
    rotor_bonus_points, rotor_bonus_rank_point, pressure_bonus_points, pressure_bonus_rank_point, 
    foul_points, foul_count, tech_foul_count,
    total_points, adjust_points
) VALUES (
    (SELECT id FROM matches WHERE key == ?), ?,
    ?, ?, ?, ?, ?, ?, ?, ?,
    ?, ?, ?, ?, ?, ?, ?, ?,
    ?, ?, ?, ?,
    ?, ?, ?,
    ?, ?
);