from pydantic import BaseModel
from typing import List
from datetime import datetime


# --------------------
# Cart Schemas
# --------------------

class AddToCartRequest(BaseModel):
    product_id: str
    quantity: int
    user_id: str


class CartItem(BaseModel):
    product_id: str
    name: str
    price: float
    quantity: int


class CartResponse(BaseModel):
    user_id: str
    items: List[CartItem]


# --------------------
# Order Schemas
# --------------------

class PlaceOrderRequest(BaseModel):
    user_id: str


class OrderResponse(BaseModel):
    message: str
    total_amount: float