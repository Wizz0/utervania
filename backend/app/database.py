import os
import asyncpg
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5433/utervania")

async def get_db():
    conn = await async.connect(DATABASE_URL)
    try:
        yield conn
    finally:
        await conn.close()