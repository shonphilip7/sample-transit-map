#!/usr/bin/bash
set -e
DB_NAME="gis"
#This list includes various utilities and libraries, the Apache web server, and carto which 
#is used to convert Carto-CSS stylesheets into something that mapnik the map renderer can understand.
sudo apt update
sudo apt install libboost-all-dev git tar unzip wget bzip2
sudo apt install build-essential autoconf libtool libxml2-dev
sudo apt install libgeos-dev libgeos++-dev libpq-dev libbz2-dev
sudo apt install libproj-dev munin-node munin protobuf-c-compiler
sudo apt install libfreetype6-dev libtiff5-dev libicu-dev
sudo apt install libgdal-dev libcairo2-dev libcairomm-1.0-dev
sudo apt install apache2 apache2-dev libagg-dev liblua5.2-dev
sudo apt install ttf-unifont lua5.1 liblua5.1-0-dev
echo "--- Dependencies installed---"
#postgresql is the database we're going to store map data and postgis adds some extra graphical support to it
sudo apt install postgresql postgresql-contrib postgis postgresql-12-postgis-3 postgresql-12-postgis-3-scripts
echo "--- Database installed ---"
sudo service postgresql start
sudo -u postgres -i <<EOF
psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname = '$USER'" | grep -q 1 || createuser $USER
if psql -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then dropdb $DB_NAME; fi
createdb -E UTF8 -O $USER $DB_NAME;
psql -d $DB_NAME -c "CREATE EXTENSION postgis;"
psql -d $DB_NAME -c "CREATE EXTENSION hstore;"
psql -d $DB_NAME -c "ALTER TABLE geometry_columns OWNER TO $USER;"
psql -d $DB_NAME -c "ALTER TABLE spatial_ref_sys OWNER TO $USER;"
EOF
echo "--- Created extensions and altered table ---"
sudo apt install osm2pgsql
echo "osm2pgsql successfully installed"
sudo apt install autoconf apache2-dev libtool libxml2-dev libbz2-dev libgeos-dev libgeos++-dev libproj-dev
sudo apt install gdal-bin libmapnik-dev mapnik-utils python3-mapnik python3-psycopg2 python3-yaml
cp get-fonts.sh $HOME
echo "--- Installed mapnik and dependencies ---"
if [ -d "$HOME/src" ]; then
    sudo rm -r "$HOME/src"
    echo "Old src directory removed."
fi
mkdir "$HOME/src"
cd "$HOME/src"
#Stylesheet for map
git clone https://github.com/gravitystorm/openstreetmap-carto
cd "$HOME/src/openstreetmap-carto"
git fetch origin
git checkout v5.6.x
echo "Installed stylesheet"
sudo apt install npm
sudo npm install -g carto
carto -v
echo "--- Installed Carto compiler ---"
carto project.mml > mapnik.xml
echo "--- Converted carto to mapnik style"
if [ -d "$HOME/data" ]; then
    sudo rm -r "$HOME/data"
    echo "Old data directory removed."
fi
mkdir "$HOME/data"
cd "$HOME/data"
wget https://download.geofabrik.de/asia/india/southern-zone-latest.osm.pbf
echo "--- Downloaded data"
osm2pgsql -d $DB_NAME --create --slim  -G --hstore --tag-transform-script $HOME/src/openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes 1 -S $HOME/src/openstreetmap-carto/openstreetmap-carto.style $HOME/data/southern-zone-latest.osm.pbf
echo "Loaded data into DB"
cd "$HOME/src/openstreetmap-carto/"
#should respond with CREATE INDEX 14 times
psql -d gis -f indexes.sql
echo "Indexes added"
cd "$HOME/src/openstreetmap-carto/"
#shapefiles for things like low-zoom country boundaries
scripts/get-external-data.py
#echo "Shapefile downloaded"
#Font script need to be updated as the one provided in gitrepo returns error
cp $HOME/get-fonts.sh $HOME/src/openstreetmap-carto/scripts/
chown $USER $HOME/src/openstreetmap-carto/scripts/get-fonts.sh
#echo "Copied new font script and changed ownership"
cd "$HOME/src/openstreetmap-carto/"
scripts/get-fonts.sh
cd "$HOME/src/openstreetmap-carto/fonts/"
#The following fonts need to be downloaded manually
wget https://gwern.net/static/font/noto-emoji/NotoEmoji-Regular.ttf
wget https://gwern.net/static/font/noto-emoji/NotoEmoji-Bold.ttf
wget https://github.com/tony/dot-fonts/raw/refs/heads/master/Hanazono/HanaMinA.ttf
wget https://github.com/tony/dot-fonts/raw/refs/heads/master/Hanazono/HanaMinB.ttf
echo "Fonts downloaded"