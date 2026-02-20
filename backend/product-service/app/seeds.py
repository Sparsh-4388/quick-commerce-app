# app/seeds.py

from app.database import db
from datetime import datetime

def seed_products():
    products_collection = db["products"]

    products = [
        {
            "product_id": "p001",
            "name": "Milk",
            "description": "Fresh dairy milk",
            "price": 50,
            "category": "Dairy",
            "image_url": "https://via.placeholder.com/150",
            "available": True,
            "created_at": datetime.utcnow()
        },
        {
            "product_id": "p002",
            "name": "Bread",
            "description": "Whole wheat bread",
            "price": 30,
            "category": "Bakery",
            "image_url": "https://via.placeholder.com/150",
            "available": True,
            "created_at": datetime.utcnow()
        }
    ]

    if products_collection.count_documents({}) == 0:
        products_collection.insert_many(products)
        print("Products seeded successfully.")
    else:
        print("Products already exist. Skipping seeding.")