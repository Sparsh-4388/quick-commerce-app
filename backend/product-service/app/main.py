from fastapi import FastAPI
from app.routes import products
from app.seeds import seed_products

app = FastAPI()

@app.on_event("startup")
def startup_event():
    seed_products()

app.include_router(products.router)