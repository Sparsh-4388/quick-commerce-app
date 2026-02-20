from pydantic import BaseModel
from typing import List


class Product(BaseModel):
    product_id: str
    name: str
    description: str
    price: float
    category: str
    image_url: str
    available: bool


class BulkProductRequest(BaseModel):
    product_ids: List[str]
