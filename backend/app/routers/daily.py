from fastapi import APIRouter, HTTPException, Depends
from datetime import date
import asyncpg
from ..database import get_db
from ..models import Level

router = APIRouter(prefix="/daily", tags=["daily"])

@router.get("/")
async def get_daily_level(conn: asyncpg.Connection = Depends(get_db)):
    """Получить уровень на сегодня"""
    today = date.today()
    
    # 1. Пробуем найти уровень в расписании
    row = await conn.fetchrow("""
        SELECT l.* 
        FROM daily_schedule d
        JOIN levels l ON d.level_id = l.id
        WHERE d.date = $1
    """, today)
    
    # 2. Если нет в расписании — берем случайный
    if not row:
        row = await conn.fetchrow("""
            SELECT * FROM levels 
            ORDER BY RANDOM() 
            LIMIT 1
        """)
        
        # Сохраняем в расписание (чтобы завтра не было снова случайным)
        if row:
            await conn.execute("""
                INSERT INTO daily_schedule (date, level_id)
                VALUES ($1, $2)
                ON CONFLICT (date) DO NOTHING
            """, today, row['id'])
    
    if not row:
        raise HTTPException(status_code=404, detail="No levels found")
    
    # Преобразуем в словарь
    level = dict(row)
    
    # Пока просто возвращаем JSON (потом добавим файл)
    return {
        "id": level['id'],
        "name": level['name'],
        "filename": level['filename']
    }