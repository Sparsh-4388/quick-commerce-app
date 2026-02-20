from fastapi import FastAPI
from app.routes import cart, order

app = FastAPI()

app.include_router(cart.router, prefix="/cart", tags=["Cart"])
app.include_router(order.router, prefix="/order", tags=["Order"])

@app.get("/")
def root():
    return {"message": "Cart-Order Service Running"}