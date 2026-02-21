# app/schemas.py
from pydantic import BaseModel

class DeliveryCreate(BaseModel):
    order_id: str
    user_id: str


class DeliveryStatusUpdate(BaseModel):
    status: str