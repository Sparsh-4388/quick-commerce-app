# app/main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.database import db
from app.schemas import DeliveryCreate, DeliveryStatusUpdate
from uuid import uuid4
from datetime import datetime

app = FastAPI(title="Delivery Service")

# Allow CORS for local testing (Flutter frontend)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

DELIVERY_COLLECTION = db["deliveries"]

# Order status flow
STATUS_FLOW = ["CREATED", "PLACED", "PACKED", "OUT_FOR_DELIVERY", "DELIVERED"]


@app.post("/delivery/create", status_code=201)
def create_delivery(delivery: DeliveryCreate):
    """
    Create a delivery for a given order.
    """
    # Prevent duplicate deliveries
    existing = DELIVERY_COLLECTION.find_one({"order_id": delivery.order_id})
    if existing:
        return {"message": "Delivery already exists", "delivery_id": existing["delivery_id"]}

    new_delivery = {
        "delivery_id": str(uuid4()),
        "order_id": delivery.order_id,
        "user_id": delivery.user_id,
        "status": "CREATED",
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    DELIVERY_COLLECTION.insert_one(new_delivery)
    return new_delivery


@app.get("/deliveries")
def list_deliveries():
    """
    List all deliveries.
    """
    deliveries = list(DELIVERY_COLLECTION.find({}, {"_id": 0}))
    return deliveries


@app.get("/delivery/{order_id}/status")
def get_delivery_status(order_id: str):
    """
    Get current status of a delivery by order_id.
    """
    delivery = DELIVERY_COLLECTION.find_one({"order_id": order_id}, {"_id": 0})
    if not delivery:
        raise HTTPException(status_code=404, detail="Delivery not found")
    return {"order_id": delivery["order_id"], "status": delivery["status"]}


@app.post("/delivery/{order_id}/update-status")
def update_delivery_status(order_id: str, update: DeliveryStatusUpdate):
    """
    Update status of a delivery.
    """
    delivery = DELIVERY_COLLECTION.find_one({"order_id": order_id})
    if not delivery:
        raise HTTPException(status_code=404, detail="Delivery not found")

    if update.status not in STATUS_FLOW:
        raise HTTPException(status_code=400, detail=f"Invalid status: {update.status}")

    DELIVERY_COLLECTION.update_one(
        {"order_id": order_id},
        {"$set": {"status": update.status, "updated_at": datetime.utcnow()}}
    )

    return {"order_id": order_id, "status": update.status}