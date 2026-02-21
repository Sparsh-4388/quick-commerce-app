#!/bin/bash

# ===============================
# RUN DEV SCRIPT — BLINKIT APP
# ===============================

echo "===================================="
echo "Starting all backend microservices..."
echo "===================================="

# Run docker-compose from backend folder without changing current directory
docker-compose -f backend/docker-compose.yml up -d

# Wait for backend services to be ready
echo "Waiting for backend services to start..."
sleep 5  # increase if services take longer

# List connected Flutter devices
echo "Detecting connected Flutter devices..."
flutter devices

# Prompt user for device ID
read -p "Enter the device ID to run Flutter on: " DEVICE_ID

echo "===================================="
echo "Starting Flutter frontend..."
echo "===================================="

cd frontend || { echo "Frontend folder not found!"; exit 1; }

# Get dependencies
flutter pub get

# Run app on chosen device
flutter run -d "$DEVICE_ID"