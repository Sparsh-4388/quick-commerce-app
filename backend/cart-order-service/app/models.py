from app.database import db

cart_collection = db["cart_items"]
order_collection = db["orders"]
order_items_collection = db["order_items"]