# app/services/cart_service.py

import requests
from app.database import db
from datetime import datetime

CART_COLLECTION = db["carts"]

PRODUCT_SERVICE_URL = "http://product-service:8000/products"


def add_to_cart(product_id: str, quantity: int, user_id: str = "default_user"):
    # 1️⃣ Validate product exists via product-service
    response = requests.get(f"{PRODUCT_SERVICE_URL}/{product_id}")

    if response.status_code != 200:
        raise Exception("Product not found")

    product = response.json()

    # 2️⃣ Find user's cart
    cart = CART_COLLECTION.find_one({"user_id": user_id})

    if not cart:
        cart = {
            "user_id": user_id,
            "items": [],
            "updated_at": datetime.utcnow()
        }
        CART_COLLECTION.insert_one(cart)

    # 3️⃣ Check if item already in cart
    existing_item = next(
        (item for item in cart["items"] if item["product_id"] == product_id),
        None
    )

    if existing_item:
        CART_COLLECTION.update_one(
            {"user_id": user_id, "items.product_id": product_id},
            {"$inc": {"items.$.quantity": quantity}}
        )
    else:
        CART_COLLECTION.update_one(
            {"user_id": user_id},
            {
                "$push": {
                    "items": {
                        "product_id": product_id,
                        "name": product["name"],
                        "price": product["price"],
                        "quantity": quantity
                    }
                }
            }
        )

    return {"message": "Item added to cart"}


def get_cart(user_id: str = "default_user"):
    cart = CART_COLLECTION.find_one({"user_id": user_id}, {"_id": 0})
    return cart if cart else {"user_id": user_id, "items": []}


def remove_from_cart(product_id: str, quantity: int, user_id: str):
    cart = CART_COLLECTION.find_one({"user_id": user_id})

    if not cart:
        raise Exception("Cart not found")

    item = next(
        (item for item in cart["items"] if item["product_id"] == product_id),
        None
    )

    if not item:
        raise Exception("Product not in cart")

    if item["quantity"] > quantity:
        # Decrease quantity
        CART_COLLECTION.update_one(
            {"user_id": user_id, "items.product_id": product_id},
            {"$inc": {"items.$.quantity": -quantity}}
        )
    else:
        # Remove item completely
        CART_COLLECTION.update_one(
            {"user_id": user_id},
            {"$pull": {"items": {"product_id": product_id}}}
        )

    return {"message": "Cart updated successfully"}