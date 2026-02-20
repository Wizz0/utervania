from fastapi import FastAPI
from .routers import daily

app = FastAPI(
    title="UterVania API",
    description="Бэкенд для игры с ежедневными уровнями",
    version="0.1.0"
)

# Подключаем роутеры
app.include_router(daily.router)

@app.get("/")
async def root():
    return {"message": "UterVania API", "status": "running"}

@app.get("/health")
async def health():
    return {"status": "healthy"}