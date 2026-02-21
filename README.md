# Blinkit Clone — B2C Quick Commerce App

A minimal but functional quick-commerce application built as an intern assignment,
inspired by Blinkit. Supports user auth, product browsing, cart management,
order placement, and delivery tracking.

---

## Architecture Overview

The backend is split into 4 independent microservices, each with its own
database collections, Dockerfile, and REST API. The Flutter frontend communicates
with each service directly via HTTP.

```
Flutter App (Mobile)
       │
       ├──► User Service        (port 8001) — auth, registration, profile
       ├──► Product Service     (port 8002) — product catalog, categories
       ├──► Cart-Order Service  (port 8003) — cart operations, order placement
       └──► Delivery Service    (port 8004) — delivery lifecycle, status tracking
                                                      │
                                             Each service has its own
                                             MongoDB Atlas collection
```

---

## Microservice Responsibilities

### 1. User Service (port 8001)
Handles user registration and login using JWT-based authentication.
Passwords are hashed using bcrypt. OTP is hardcoded as `1234` for simplicity.

### 2. Product Catalog Service (port 8002)
Manages the product listing. Products are pre-seeded into MongoDB on startup.
Provides endpoints to list all products, filter by category, and fetch a single product.

### 3. Cart & Order Service (port 8003)
Manages the shopping cart per user. On order placement, it calculates the total,
saves the order, notifies the delivery service, and clears the cart.

### 4. Delivery Service (port 8004)
Tracks the delivery lifecycle for each order. Status flows through:
`CREATED → PLACED → PACKED → OUT_FOR_DELIVERY → DELIVERED`

---

## API List

### User Service
| Method | Endpoint  | Description        |
|--------|-----------|--------------------|
| POST   | /register | Register new user  |
| POST   | /login    | Login, returns JWT |
| GET    | /profile  | Get user profile   |

### Product Service
| Method | Endpoint               | Description         |
|--------|------------------------|---------------------|
| GET    | /products              | List all products   |
| GET    | /products/{product_id} | Get single product  |
| GET    | /categories            | List all categories |

### Cart & Order Service
| Method | Endpoint         | Description               |
|--------|------------------|---------------------------|
| POST   | /cart/add        | Add item to cart          |
| POST   | /cart/remove     | Remove item from cart     |
| GET    | /cart/{user_id}  | Get user's cart           |
| POST   | /order/create    | Place order from cart     |
| GET    | /order/{user_id} | Get user's order history  |

### Delivery Service
| Method | Endpoint                           | Description             |
|--------|------------------------------------|-------------------------|
| POST   | /delivery/create                   | Create delivery record  |
| GET    | /delivery/{order_id}/status        | Get delivery status     |
| POST   | /delivery/{order_id}/update-status | Update delivery status  |

---

## Flutter Screens

| Screen               | Description                                       |
|----------------------|---------------------------------------------------|
| Login                | Email + password login with JWT                   |
| Signup               | Register with name, email, password + auto-login  |
| Home                 | Product grid with category filter chips           |
| Product Detail       | Full product info, quantity selector, add to cart |
| Cart                 | View cart items, total, place order               |
| Order Confirmation   | Success screen with order summary                 |
| Order Tracking       | Live status tracker, polls every 10 seconds       |
| Orders History       | All past orders with track button on each         |

---

## How to Run

### Prerequisites
- Docker + Docker Compose
- Flutter SDK
- Android device connected via ADB

### Option 1 — Convenience script (recommended)
```bash
chmod +x run_dev.sh
./run_dev.sh
```
The script starts all backend services, detects connected Flutter devices,
prompts you to pick one, and launches the app.

### Option 2 — Manual
```bash
# Start backend
docker-compose -f backend/docker-compose.yml up -d

# Start Flutter
cd frontend
flutter pub get
flutter run
```

### Rebuilding a service after code changes
```bash
docker-compose -f backend/docker-compose.yml up -d --build <service-name>
```

---

## Kubernetes (Local with Minikube)

Kubernetes manifests are in the `k8s/` folder for local deployment using minikube.

```bash
# Start minikube
minikube start

# Point Docker to minikube's registry
eval $(minikube docker-env)

# Build all images inside minikube
docker build -t user-service:latest ./backend/user-service
docker build -t product-service:latest ./backend/product-service
docker build -t cart-order-service:latest ./backend/cart-order-service
docker build -t delivery-service:latest ./backend/delivery-service

# Deploy everything
kubectl apply -f k8s/

# Check pods
kubectl get pods

# Get minikube IP
minikube ip
```

Services are exposed on:
- User Service    → minikube-ip:30001
- Product Service → minikube-ip:30002
- Cart-Order      → minikube-ip:30003
- Delivery        → minikube-ip:30004

---

## Project Structure

```
mobile_application_blinkit/
├── backend/
│   ├── user-service/
│   ├── product-service/
│   ├── cart-order-service/
│   ├── delivery-service/
│   └── docker-compose.yml
├── frontend/
│   └── lib/
│       ├── main.dart
│       ├── screens/
│       │   ├── login_screen.dart
│       │   ├── signup_screen.dart
│       │   ├── home_screen.dart
│       │   ├── product_detail_screen.dart
│       │   ├── cart_screen.dart
│       │   ├── order_confirmation_screen.dart
│       │   ├── order_tracking_screen.dart
│       │   └── orders_screen.dart
│       └── services/
│           └── api_service.dart
├── k8s/
│   ├── mongo.yaml
│   ├── user-service.yaml
│   ├── product-service.yaml
│   ├── cart-order-service.yaml
│   └── delivery-service.yaml
├── run_dev.sh
└── README.md
```

---

## Assumptions Made

- OTP for registration is hardcoded as `1234` — no SMS or email service used
- No payment gateway — orders are assumed prepaid on placement
- Product images use Unsplash URLs — no file upload system
- Delivery status updates are manual via API — no real logistics integration
- Internal microservice communication is trusted — no auth between services
- MongoDB Atlas is used as the database — no local MongoDB container

---

## Known Limitations

- Search bar UI exists but is not wired to backend
- No pagination on product listing
- JWT tokens are not refreshed — user must re-login after expiry
- Delivery status must be updated manually via the delivery service API
- No admin dashboard to manage products or orders

---

## AI Tools Used

- **Claude (Anthropic)** — Flutter screen generation, API integration debugging,
  Kubernetes manifests, README
- **ChatGPT** — Backend FastAPI scaffolding and boilerplate generation
 
### What was AI-assisted
- Flutter screen code (home, cart, orders, tracking, confirmation, product detail)
- Kubernetes YAML manifests
- Debugging import conflicts and API response shape mismatches

### What was implemented or customized manually
- Color theme and UI design decisions on the Flutter frontend
- Backend microservice logic and data models
- MongoDB Atlas setup and product seeding
- Docker Compose configuration
- `run_dev.sh` convenience script
- End-to-end integration and testing