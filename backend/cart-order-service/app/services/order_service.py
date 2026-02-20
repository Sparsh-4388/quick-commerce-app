# app/services/order_service.py
import uuid
from app.database import db
from app.services.cart_service import get_cart
from datetime import datetime

ORDER_COLLECTION = db["orders"]
CART_COLLECTION = db["carts"]


def place_order(user_id: str):
    cart = get_cart(user_id)

    if not cart or not cart.get("items"):
        raise Exception("Cart is empty")

    total_amount = 0

    for item in cart["items"]:
        total_amount += item["price"] * item["quantity"]

    order = {
        "order_id": str(uuid.uuid4()),
        "user_id": user_id,
        "items": cart["items"],
        "total_amount": total_amount,
        "created_at": datetime.utcnow(),
        "status": "PLACED"
    }

    ORDER_COLLECTION.insert_one(order)

    # Clear cart after order
    CART_COLLECTION.update_one(
        {"user_id": user_id},
        {"$set": {"items": []}}
    )

    return {
        "message": "Order placed successfully",
        "order_id": order["order_id"],
        "total_amount": total_amount,
        "created_at": order["created_at"]
    }

def get_orders(user_id: str):
    orders = list(
        ORDER_COLLECTION.find(
            {"user_id": user_id},
            {"_id": 0}
        )
    )
    return orders