A starter project for displaying map of a region using pre-generate raster tiles. The region chosen for this project is the state of Kerala with its raster images in the "tiles" directory in the format {z}/{x}/{y} where z is zoom level, x is the horizontal and y is the vertical position of tile. The map style is based on the styles used by the <a href="https://www.openstreetmap.org/">openstreetmap</a> project. The repo includes a sample script(map.html) to show how to display maps on the browser using <a href="https://leafletjs.com/">leaflet</a>.
## Prerequisites
1. Run the setup_tile_env.sh script. These are a list of commands from this <a href="https://switch2osm.org/serving-tiles/manually-building-a-tile-server-ubuntu-20-04-lts">blog</a> for installing all necessary packages.
2. Run the generate_tiles.py script in . This is a modified version of the script from the <a href="https://github.com/openstreetmap/mapnik-stylesheets/blob/master/generate_tiles.py">openstreetmap project</a>.
3. Docker
<p>
  The end result of running the above two scripts is the 'tiles' directory which is already included in this repo so no need to run the scripts unless they need to be modified as per personal requirement. Ideally, these scripts would be in the Dockerfile to avoid installing unnecessary packages on the local machine but the image size would have been above 20 GB so it was not included.   
</p>

## Displaying the tiles
1. git clone https://github.com/shonphilip7/sample-transit-map.git
2. docker build -t map-tiles-image:1.0 .
3. docker run -d --name map-tiles-container -p 8080:80 map-tiles-image:1.0
<p>
  At this point opening the browser to http://localhost:8080/map.html should show a map of Kerala with the KMRL route based on a static lat and lon from R1_1.json file. This JSON file is mockup of the API from <a href="https://github.com/shonphilip7/transit-app-api">this repo</a>.</p> 
<p>
Using locally hosted map tiles (self-hosting) offers significant benefits related to control and performance compared to referencing openstreetmap directly from the official host.
<pre>
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);
</pre>
</p>  
