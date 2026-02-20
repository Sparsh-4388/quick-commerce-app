from fastapi import APIRouter, HTTPException
from app.database import db
from app.schemas import Product, BulkProductRequest
from typing import List

router = APIRouter()


@router.get("/products", response_model=List[Product])
def get_products():
    return list(db.products.find({}, {"_id": 0}))


@router.get("/products/{product_id}", response_model=Product)
def get_product(product_id: str):
    product = db.products.find_one(
        {"product_id": product_id},
        {"_id": 0}
    )

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    return product


@router.get("/categories")
def get_categories():
    categories = db.products.distinct("category")
    return [{"name": c} for c in categories]


@router.post("/products/bulk", response_model=List[Product])
def get_products_bulk(request: BulkProductRequest):
    products = list(
        db.products.find(
            {"product_id": {"$in": request.product_ids}},
            {"_id": 0}
        )
    )
    return products
