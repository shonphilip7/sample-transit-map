A starter project for displaying map of a region using pre-generated tiles. The region chosen for this project is the state of Kerala with its map tiles in the "tiles" directory in the format {z}/{x}/{y} where z is zoom level, x is the horizontal and y is the vertical position of tile. The map style is based on the styles used by the <a href="https://www.openstreetmap.org/">openstreetmap</a> project. This repo includes a sample script to show how to display maps on the browser using <a href="https://leafletjs.com/">leaflet</a>.
## Generating the tiles directory
While not part of the dockerfile, tiles directory is required for displaying the map. Following are the steps for generating tiles:
1. Run the setup_tile_env.sh script. The script references commands from https://switch2osm.org/serving-tiles/manually-building-a-tile-server-ubuntu-20-04-lts/ </br>
2. Once the environment is set, run the the python script generate_tiles.py to generate tiles. This script is a modified version of https://github.com/openstreetmap/mapnik-stylesheets/blob/master/generate_tiles.py </br>
<p>Running the above steps should generate the tiles directory. As the tiles directory is already included in the repo the above steps are not required. The reason to not include the script for generating tiles in the dockerfile itself is that it would take a long time for docker to build. </p>

## Displaying the tiles
1. git clone https://github.com/shonphilip7/sample-transit-map.git </br>
2. docker build -t map-tiles-image:1.0 . </br>
3. docker run -d --name map-tiles-container -p 8080:80 map-tiles-image:1.0 </br>
At this point opening the browser to http://localhost:8080/map.html should show a map of Kerala.  
