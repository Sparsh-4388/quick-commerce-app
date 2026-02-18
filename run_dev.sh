#!/bin/bash

echo "Starting backend..."
cd backend
python app/main.py &

echo "Starting Flutter frontend..."
cd ../frontend
flutter run

