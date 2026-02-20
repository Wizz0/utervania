import os
import asyncio
import asyncpg
from dotenv import load_dotenv

load_dotenv()
print("DATABASE_URL из env:", os.getenv("DATABASE_URL"))

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5433/utervania")

async def get_db():
    """Подключение к базе данных"""
    conn = await asyncpg.connect(DATABASE_URL)
    try:
        yield conn
    finally:
        await conn.close()