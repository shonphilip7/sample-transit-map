#!/bin/bash
set -e
# Define target Geofabrik URLs and directories
URL="https://download.geofabrik.de/asia/india"
DATA_DIR="/tmp/map-data"
# -p flag creates nested folders and prevents error if the folder already exists
mkdir -p "$DATA_DIR"
# Download the data file
if [ ! -f "$DATA_DIR/southern-zone-latest.osm.pbf" ]; then
    echo "Downloading Southern Zone map from Geofabrik..."
    wget -c "$URL/southern-zone-latest.osm.pbf" -O "$DATA_DIR/southern-zone-latest.osm.pbf"
else
    echo "Map file already exists, skipping download."
fi
# Ensure the PostgreSQL cluster service is running
echo "Starting PostgreSQL..."
pg_ctlcluster 12 main start
until pg_isready -q; do
    sleep 1
done
# Import the data using osm2pgsql
# Executed as the postgres user to match database credentials
echo "Starting osm2pgsql spatial import..."
su - postgres -c "osm2pgsql \
    --create \
    --database gis \
    --slim \
    --cache 2500 \
    --number-processes 1 \
    -G \
    --hstore \
    --style /src/openstreetmap-carto.style \
    --tag-transform-script /src/openstreetmap-carto.lua \
    $DATA_DIR/southern-zone-latest.osm.pbf"
# Cleanup to minimize final container layer bloat
rm -rf "$DATA_DIR/southern-zone-latest.osm.pbf"
# Cleanly stop the database to flush memory changes to disk
echo "Stopping database cleanly..."
pg_ctlcluster 12 main stop
