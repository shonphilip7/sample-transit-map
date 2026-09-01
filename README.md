# Kerala Map Tile Server 🗺️

A fully containerized **Docker-based map server** that renders and serves interactive map tiles of the **Kerala state region**. The project ingests OpenStreetMap data into a PostGIS database, processes them into standard `x/y/z` PNG tile formats using the official Mapnik style sheet, and displays them via a lightweight **Leaflet.js** frontend.

---

## 📋 Table of Contents
- [Architecture & Data Flow](#-architecture--data-flow)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
  - [Building the Image](#1-building-the-image)
  - [Running the Container](#2-running-the-container)
- [Configuration & Details](#-configuration--details)
- [Tech Stack](#-tech-stack)

---

## 🗺️ Architecture & Data Flow

The entire data pipeline and hosting environment are self-contained within Docker:
1. **Data Source:** Downloads the South India `.pbf` extract from **Geofabrik** (OpenStreetMap data).
2. **Database Ingestion:** Imports spatial data into a temporary **PostGIS** database during the build phase.
3. **Tile Generation:** Runs a custom `generate_tiles.py` script which reads the imported data, applies the Mapnik stylesheet, and pre-renders the map into standard `x/y/z` structure PNG tiles specifically for the Kerala region.
4. **Frontend Delivery:** Serves the static tile assets to customers using an interactive **Leaflet.js** web interface.

---

## ⚙️ Prerequisites

You only need **Docker** installed on your host machine. All dependencies, databases, spatial tools, and processing scripts are handled internally during the Docker build process.

* [Install Docker](https://docker.com)

---

## 🚀 Getting Started

### 1. Building the Image
Because the database import, tool setups, and tile generation (`generate_tiles.py`) run during the build phase, the initial build will take some time depending on your hardware.

Run the following command in your terminal:
```bash
docker build -t map-tiles-image:1.0 .
```

### 2. Running the Container
Once built, you can spin up the application with a simple `docker run` command. Map a local port of your choice (e.g., `8080`) to the container's internal web server port (`80`).

```bash
docker run -d --name map-tiles-container -p 8080:80 map-tiles-image:1.0
```

After running the command, open your web browser and navigate to:
👉 **`http://localhost:8080/map.html`** to view the Leaflet map. At this point it should show a map of Kerala with the path taken by Route 1 KMRL transit agency based on lat and lon entries from JSON file in the data directory.

---

## 🛠️ Configuration & Details

* **Map Styling:** The map tiles are rendered using the standard OpenStreetMap cartography style driven by **`mapnik.xml`**.
* **Zoom Levels:** The `generate_tiles.py` script pre-renders tiles strictly from **zoom level 9 to 15**, optimized specifically to cover the bounds of Kerala with high performance. 
* **Tile Cache:** The output structure follows standard OpenStreetMap formats (`/zoom/x/y.png`), making it highly performant as the frontend serves static PNG assets rather than querying a database in real time.

---

## 💻 Tech Stack

* **Infrastructure:** [Docker](https://docker.com)
* **Database:** [PostGIS](https://postgis.net) (PostgreSQL)
* **Tile Rendering:** [Mapnik](https://mapnik.org) (`mapnik.xml`) & Python 3 (`generate_tiles.py`)
* **Map Data:** [OpenStreetMap](https://openstreetmap.org) via [Geofabrik](https://geofabrik.de)
* **Frontend:** [Leaflet.js](https://leafletjs.com)
