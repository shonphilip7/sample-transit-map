#!/bin/bash
set -e
echo "Starting PostgreSQL..."
pg_ctlcluster 12 main start
until pg_isready -q; do
    sleep 1
done
echo "PostgreSQL is ready!"
echo "Generating tiles..."
# Run your tile generation script
python3 /app/scripts/generate_tiles.py
echo "Stopping database cleanly..."
pg_ctlcluster 12 main stop