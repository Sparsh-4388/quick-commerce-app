from fastapi import APIRouter, HTTPException
from app.services.cart_service import add_to_cart, get_cart, remove_from_cart
from app.schemas import AddToCartRequest

router = APIRouter()


@router.post("/add")
def add_item(request: AddToCartRequest):
    try:
        return add_to_cart(
            request.product_id,
            request.quantity,
            request.user_id
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{user_id}")
def fetch_cart(user_id: str):
    return get_cart(user_id)


@router.post("/remove")
def remove_item(request: AddToCartRequest):
    return remove_from_cart(
        request.product_id,
        request.quantity,
        request.user_id
    )
