from pymongo import MongoClient
import os

MONGO_URL = os.getenv("MONGO_URL")
if not MONGO_URL:
    raise ValueError("MONGO_URL is not set")
client = MongoClient(MONGO_URL)
db = client.get_database()
users_collection = db["users"]

# Ensure unique email
users_collection.create_index("email", unique=True)