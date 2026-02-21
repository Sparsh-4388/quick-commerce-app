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
            "image_url": "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400",
            "available": True,
            "created_at": datetime.utcnow()
        },
        {
            "product_id": "p002",
            "name": "Bread",
            "description": "Whole wheat bread",
            "price": 30,
            "category": "Bakery",
            "image_url": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400",
            "available": True,
            "created_at": datetime.utcnow()
        },
        {
            "product_id": "p003",
            "name": "Eggs",
            "description": "Farm fresh eggs",
            "price": 80,
            "category": "Dairy",
            "image_url": "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400",
            "available": True,
            "created_at": datetime.utcnow()
        },
        {
            "product_id": "p004",
            "name": "Banana",
            "description": "Fresh bananas",
            "price": 40,
            "category": "Fruits",
            "image_url": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400",
            "available": True,
            "created_at": datetime.utcnow()
        },
        {
            "product_id": "p005",
            "name": "Tomato",
            "description": "Fresh red tomatoes",
            "price": 25,
            "category": "Vegetables",
            "image_url": "https://images.unsplash.com/photo-1546470427-e26264be0b0d?w=400",
            "available": True,
            "created_at": datetime.utcnow()
        },
        {
            "product_id": "p006",
            "name": "Orange Juice",
            "description": "Fresh squeezed orange juice",
            "price": 90,
            "category": "Beverages",
            "image_url": "https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400",
            "available": True,
            "created_at": datetime.utcnow()
        },

    ]

    if products_collection.count_documents({}) == 0:
        products_collection.insert_many(products)
        print("Products seeded successfully.")
    else:
        print("Products already exist. Skipping seeding.")