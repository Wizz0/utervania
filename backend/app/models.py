from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional

# Модель для уровня
class Level(BaseModel):
    id: int
    filename: str
    name: Optional[str] = None
    description: Optional[str] = None
    created_at: datetime

# Модель для создания уровня (без id, который создается в БД)
class LevelCreate(BaseModel):
    filename: str
    name: Optional[str] = None
    description: Optional[str] = None

# Модель для расписания
class DailySchedule(BaseModel):
    id: int
    date: date
    level_id: int