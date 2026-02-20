from fastapi import APIRouter, HTTPException, Depends
import asyncpg
from ..database import get_db
from ..models import RunSubmit

router = APIRouter(prefix="/runs", tags=["runs"])

@router.post("/submit")
async def submit_run(
    run: RunSubmit,
    conn: asyncpg.Connection = Depends(get_db)
):
    """Сохранить результат забега"""
    
    # Пока user_id = 1 (потом заменим на реального пользователя)
    user_id = 1
    
    # Простая формула подсчета очков (потом усложним)
    score = int(run.time * 1000) + (run.items_collected * 500) - (run.deaths * 200)
    
    try:
        # Сохраняем в БД
        run_id = await conn.fetchval("""
            INSERT INTO runs (user_id, level_id, time, items_count, death_count, score)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id
        """, user_id, run.level_id, run.time, run.items_collected, run.deaths, score)
        
        return {
            "status": "ok",
            "run_id": run_id,
            "score": score,
            "message": "Результат сохранен"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка сохранения: {str(e)}")