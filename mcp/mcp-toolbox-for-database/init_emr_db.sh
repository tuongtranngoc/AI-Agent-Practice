#!/bin/bash

# Script to initialize EMR database
# This script assumes PostgreSQL is running in Docker

echo "Initializing EMR Database..."

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 5

# Execute the SQL script
docker exec -i postgres-emr psql -U admin -d postgres < setup_emr_db.sql

if [ $? -eq 0 ]; then
    echo "✅ EMR database initialized successfully!"
    echo ""
    echo "Database details:"
    echo "  - Database: emr_db"
    echo "  - User: emr_user"
    echo "  - Password: emr-password"
    echo "  - Host: 0.0.0.0"
    echo "  - Port: 5432"
    echo ""
    echo "Update your tools.yaml with these credentials:"
    echo "  user: emr_user"
    echo "  password: emr-password"
else
    echo "❌ Failed to initialize EMR database"
    exit 1
fi

