CREATE TABLE daily_schedule (
	id SERIAL PRIMARY KEY,
	date DATE UNIQUE NOT NULL,
	level_id INTEGER REFERENCES levels(id)
);
