from fastapi import APIRouter, HTTPException
from app.schemas import CreateDeliveryRequest, UpdateStatusRequest
from app.services.delivery_service import (
    create_delivery,
    get_deliveries,
    update_delivery_status
)

router = APIRouter()

@router.post("/create")
def create(request: CreateDeliveryRequest):
    try:
        return create_delivery(request.order_id, request.user_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{user_id}")
def fetch(user_id: str):
    return get_deliveries(user_id)


@router.put("/update-status")
def update(request: UpdateStatusRequest):
    return update_delivery_status(request.delivery_id, request.status)