from fastapi import APIRouter, HTTPException
from app.services.order_service import place_order, get_orders
from app.schemas import PlaceOrderRequest

router = APIRouter()


@router.post("/create")
def create_order(request: PlaceOrderRequest):
    try:
        return place_order(request.user_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{user_id}")
def fetch_orders(user_id: str):
    return get_orders(user_id)