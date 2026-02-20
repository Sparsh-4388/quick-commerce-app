from app.database import db


def seed():
    db.products.delete_many({})

    db.products.insert_many([
        {
            "product_id": "p001",
            "name": "Fresh Milk",
            "description": "1L full cream milk",
            "price": 55,
            "category": "Dairy",
            "image_url": "https://via.placeholder.com/150",
            "available": True
        },
        {
            "product_id": "p002",
            "name": "Bananas",
            "description": "1 dozen bananas",
            "price": 40,
            "category": "Fruits",
            "image_url": "https://via.placeholder.com/150",
            "available": True
        },
        {
            "product_id": "p003",
            "name": "Potato Chips",
            "description": "200g salted chips",
            "price": 30,
            "category": "Snacks",
            "image_url": "https://via.placeholder.com/150",
            "available": True
        }
    ])

    print("Seeded successfully!")


if __name__ == "__main__":
    seed()
