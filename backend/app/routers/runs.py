from fastapi import APIRouter, HTTPException, Depends
from datetime import date
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

@router.get("/leaderboard/today")
async def get_today_leaderboard(
    limit: int = 10,
    include_user_stats: bool = False,  # опционально
    conn: asyncpg.Connection = Depends(get_db)
):
    """Получить топ результатов для сегодняшнего уровня"""
    
    # Узнаем сегодняшний уровень
    today_level = await conn.fetchval("""
        SELECT level_id FROM daily_schedule 
        WHERE date = $1
    """, date.today())
    
    if not today_level:
        return {"message": "Сегодня нет активного уровня"}
    
    # Топ за сегодня
    rows = await conn.fetch("""
        SELECT 
            r.id,
            r.user_id,
            COALESCE(u.username, 'Игрок ' || r.user_id) as username,
            r.score,
            r.time,
            r.items_count,
            r.death_count,
            r.date,
            -- Место игрока в общем рейтинге (опционально)
            (
                SELECT COUNT(DISTINCT user_id) + 1
                FROM runs r2
                WHERE r2.user_id != r.user_id 
                  AND r2.score > (
                      SELECT SUM(score) 
                      FROM runs r3 
                      WHERE r3.user_id = r.user_id
                  )
            ) as alltime_rank
        FROM runs r
        LEFT JOIN users u ON r.user_id = u.id
        WHERE r.level_id = $1
        ORDER BY r.score DESC, r.time ASC
        LIMIT $2
    """, today_level, limit)
    
    # Добавляем информацию об уровне
    level_info = await conn.fetchrow("""
        SELECT name, filename 
        FROM levels WHERE id = $1
    """, today_level)
    
    return {
        "level": dict(level_info) if level_info else None,
        "date": date.today(),
        "total_runs_today": await conn.fetchval(
            "SELECT COUNT(*) FROM runs WHERE level_id = $1", 
            today_level
        ),
        "leaderboard": [dict(row) for row in rows]
    }

@router.get("/leaderboard/alltime")
async def get_alltime_leaderboard(
    limit: int = 10,
    conn: asyncpg.Connection = Depends(get_db)
):
    """Получить общий топ игроков по сумме очков за все время"""
    
    rows = await conn.fetch("""
        SELECT 
            r.user_id,
            COALESCE(u.username, 'Игрок ' || r.user_id) as username,
            COUNT(*) as total_runs,
            SUM(r.score) as total_score,
            AVG(r.score) as avg_score,
            MAX(r.score) as best_score,
            SUM(r.time) as total_time,
            SUM(r.items_count) as total_items,
            SUM(r.death_count) as total_deaths
        FROM runs r
        LEFT JOIN users u ON r.user_id = u.id
        GROUP BY r.user_id, u.username
        ORDER BY total_score DESC
        LIMIT $1
    """, limit)
    
    return [dict(row) for row in rows]

@router.get("/leaderboard/{level_id}")
async def get_leaderboard(
    level_id: int,
    limit: int = 10,
    conn: asyncpg.Connection = Depends(get_db)
):
    """Получить топ результатов для уровня"""
    
    rows = await conn.fetch("""
        SELECT 
            r.id,
            r.user_id,
            COALESCE(u.username, 'Игрок ' || r.user_id) as username,
            r.score,
            r.time,
            r.items_count,
            r.death_count,
            r.date
        FROM runs r
        LEFT JOIN users u ON r.user_id = u.id
        WHERE r.level_id = $1
        ORDER BY r.score DESC, r.time ASC
        LIMIT $2
    """, level_id, limit)
    
    return [dict(row) for row in rows]

@router.get("/player/{user_id}")
async def get_player_stats(
    user_id: int,
    conn: asyncpg.Connection = Depends(get_db)
):
    """Получить статистику конкретного игрока"""
    
    # Общая статистика
    total_stats = await conn.fetchrow("""
        SELECT 
            COUNT(*) as total_runs,
            SUM(score) as total_score,
            AVG(score) as avg_score,
            MAX(score) as best_score,
            SUM(time) as total_time,
            AVG(time) as avg_time,
            SUM(items_count) as total_items,
            AVG(items_count) as avg_items,
            SUM(death_count) as total_deaths,
            AVG(death_count) as avg_deaths
        FROM runs
        WHERE user_id = $1
    """, user_id)
    
    # Статистика по дням (последние 5 забегов)
    recent_runs = await conn.fetch("""
        SELECT 
            r.*,
            l.name as level_name
        FROM runs r
        JOIN levels l ON r.level_id = l.id
        WHERE r.user_id = $1
        ORDER BY r.date DESC
        LIMIT 5
    """, user_id)
    
    # Лучший результат на сегодняшнем уровне (если есть)
    today_level = await conn.fetchval("""
        SELECT level_id FROM daily_schedule 
        WHERE date = $1
    """, date.today())
    
    today_best = None
    if today_level:
        today_best = await conn.fetchrow("""
            SELECT * FROM runs
            WHERE user_id = $1 AND level_id = $2
            ORDER BY score DESC
            LIMIT 1
        """, user_id, today_level)
    
    # Место в общем рейтинге
    alltime_rank = await conn.fetchval("""
        SELECT COUNT(DISTINCT user_id) + 1
        FROM runs
        WHERE user_id != $1
        GROUP BY user_id
        HAVING SUM(score) > (
            SELECT SUM(score) FROM runs WHERE user_id = $1
        )
        LIMIT 1
    """, user_id)
    
    return {
        "user_id": user_id,
        "total_stats": dict(total_stats) if total_stats else {},
        "recent_runs": [dict(run) for run in recent_runs],
        "today_best": dict(today_best) if today_best else None,
        "alltime_rank": alltime_rank or 1
    }