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

# Модель для отправки результата
class RunSubmit(BaseModel):
    level_id: int
    time: float          # время в секундах
    items_collected: int
    deaths: int = 0
    # user_id пока не передаем (будет из авторизации)

# Модель для ответа с результатом
class RunResponse(BaseModel):
    id: int
    level_id: int
    score: int
    time: float
    items_count: int
    deaths_count: int
    created_at: datetime