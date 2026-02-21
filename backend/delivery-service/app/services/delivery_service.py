from app.database import db
from datetime import datetime
import uuid

DELIVERY_COLLECTION = db["deliveries"]

def create_delivery(order_id: str, user_id: str):
    delivery = {
        "delivery_id": str(uuid.uuid4()),
        "order_id": order_id,
        "user_id": user_id,
        "status": "CREATED",
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }

    DELIVERY_COLLECTION.insert_one(delivery)
    delivery.pop("_id", None)
    return delivery


def get_deliveries(user_id: str):
    return list(
        DELIVERY_COLLECTION.find(
            {"user_id": user_id},
            {"_id": 0}
        )
    )


def update_delivery_status(delivery_id: str, status: str):
    DELIVERY_COLLECTION.update_one(
        {"delivery_id": delivery_id},
        {
            "$set": {
                "status": status,
                "updated_at": datetime.utcnow()
            }
        }
    )

    return {"message": "Delivery status updated"}