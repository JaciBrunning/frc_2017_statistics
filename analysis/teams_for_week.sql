SELECT event_teams.team, events.key as [Event Key], events.name as [Event Name] FROM events
INNER JOIN event_teams ON event_teams.event == events.id
WHERE julianday(events.start_date) >= julianday("START_DATE") AND julianday(events.end_date) <= julianday("END_DATE")
ORDER BY event_teams.team ASC