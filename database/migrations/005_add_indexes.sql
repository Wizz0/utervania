CREATE INDEX idx_daily_date ON daily_schedule(date);
CREATE INDEX idx_runs_user ON runs(user_id);
CREATE INDEX idx_runs_level ON runs(level_id);
CREATE INDEX idx_runs_score ON runs(score DESC);
