from pymongo import MongoClient
import os

MONGO_URL = os.getenv("MONGO_URL", "mongodb://mongo:27017")

client = MongoClient(MONGO_URL)
db = client["product_db"]

# Ensure unique product_id
db.products.create_index("product_id", unique=True)
