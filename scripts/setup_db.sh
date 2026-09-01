#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status
echo "Starting PostgreSQL temporarily for setup..."
# service postgresql start WILL NOT work during docker build layers
pg_ctlcluster 12 main start
# 2. Wait for the server to become responsive
until pg_isready -q; do
    echo "Waiting for PostgreSQL to start..."
    sleep 1
done
echo "Creating user 'renderaccount'..."
createuser renderaccount
echo "Creating gis database..."
createdb -E UTF8 -O renderaccount gis
echo "Enabling PostGIS extension in 'gis' database..."
psql -d gis -c "CREATE EXTENSION IF NOT EXISTS postgis;"
echo "Enabling HSTORE extension in 'gis' database..."
psql -d gis -c "CREATE EXTENSION IF NOT EXISTS hstore;"
echo "Reassigning PostGIS object ownership..."
psql -d gis -c "ALTER TABLE geometry_columns OWNER TO renderaccount;"
psql -d gis -c "ALTER TABLE spatial_ref_sys OWNER TO renderaccount;"
echo "Stopping temporary PostgreSQL cleanly..."
pg_ctlcluster 12 main stop