from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import FileResponse
from datetime import date
import asyncpg
import os
from ..database import get_db

router = APIRouter(prefix="/daily", tags=["daily"])

# Путь к папке с файлами уровней
LEVELS_DIR = os.path.join(os.path.dirname(__file__), "../../../level_files")

@router.get("/")
async def get_daily_level(conn: asyncpg.Connection = Depends(get_db)):
    """Получить файл уровня на сегодня"""
    
    today = date.today()
    
    # 1. Ищем уровень в расписании
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
        
        if row:
            await conn.execute("""
                INSERT INTO daily_schedule (date, level_id)
                VALUES ($1, $2)
                ON CONFLICT (date) DO NOTHING
            """, today, row['id'])
    
    if not row:
        raise HTTPException(status_code=404, detail="No levels found")
    
    level = dict(row)
    
    # 3. Формируем путь к файлу
    file_path = os.path.join(LEVELS_DIR, level['filename'])
    
    # 4. Проверяем, существует ли файл
    if not os.path.exists(file_path):
        raise HTTPException(
            status_code=404, 
            detail=f"Level file {level['filename']} not found on server"
        )
    
    # 5. Отдаем файл
    return FileResponse(
        path=file_path,
        filename=level['filename'],
        media_type="application/octet-stream",
        # headers={
        #     "X-Level-Name": level['name'] or "",
        #     "X-Level-ID": str(level['id'])
        # }
    )