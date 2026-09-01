#!/bin/bash
set -e
# Ensure the PostgreSQL cluster service is running
echo "Starting PostgreSQL..."
pg_ctlcluster 12 main start
until pg_isready -q; do
    sleep 1
done
# Execute the script file as the postgres user
echo "Starting index creation on 'gis' database..."
psql -d gis -f /src/indexes.sql
# Run the python script to pull coastlines, water bodies, and borders
echo "Downloading shapefiles for low-zoom country boundaries..."
python3 /src/scripts/get-external-data.py
echo "Stopping database cleanly..."
pg_ctlcluster 12 main stop