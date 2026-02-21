# app/services/order_service.py
import uuid
from datetime import datetime
import requests
from app.database import db
from app.services.cart_service import get_cart

ORDER_COLLECTION = db["orders"]
CART_COLLECTION = db["carts"]
DELIVERY_COLLECTION = db["deliveries"]  # optional local check
DELIVERY_SERVICE_URL = "http://delivery-service:8000/delivery/create"


def notify_delivery_service(order_id: str, user_id: str):
    """
    Call the delivery service to create a delivery for the order.
    Prevent duplicates by checking locally first.
    """
    # Check local delivery collection first (optional)
    existing = DELIVERY_COLLECTION.find_one({"order_id": order_id})
    if existing:
        print(f"Delivery already exists for order {order_id}")
        return

    payload = {"order_id": order_id, "user_id": user_id}
    try:
        response = requests.post(DELIVERY_SERVICE_URL, json=payload, timeout=5)
        if response.status_code == 201 or response.status_code == 200:
            print(f"Delivery created for order {order_id}")
            # Optionally store locally as reference
            DELIVERY_COLLECTION.insert_one({"order_id": order_id, "user_id": user_id})
        else:
            print(f"Delivery service returned {response.status_code}: {response.text}")
    except Exception as e:
        print(f"Failed to notify delivery service: {str(e)}")


def place_order(user_id: str):
    cart = get_cart(user_id)
    if not cart or not cart.get("items"):
        raise Exception("Cart is empty")

    total_amount = sum(item["price"] * item["quantity"] for item in cart["items"])

    order = {
        "order_id": str(uuid.uuid4()),
        "user_id": user_id,
        "items": cart["items"],
        "total_amount": total_amount,
        "created_at": datetime.utcnow(),
        "status": "PLACED"
    }

    ORDER_COLLECTION.insert_one(order)

    # Notify delivery service safely
    notify_delivery_service(order["order_id"], user_id)

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
    return list(
        ORDER_COLLECTION.find({"user_id": user_id}, {"_id": 0})
    )