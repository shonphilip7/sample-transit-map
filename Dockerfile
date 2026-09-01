# 1. Specify the base image with the desired tag
FROM ubuntu:20.04
# 2. Avoid prompts and interactive dialogs during installation
ENV DEBIAN_FRONTEND=noninteractive
# 3. Update the package list and install system dependencies
# This list includes various utilities and libraries:
# - the Apache web server
# - carto which is used to convert Carto-CSS stylesheets into something 
# that mapnik can understand
# - postgresql is the database we're going to store map data
# - postgis adds some extra graphical support to it
# - mapnik (the map renderer)
# Combine RUN commands and clean up cache to keep the image small
RUN apt-get update && apt-get install -y \
    apache2 \
    apache2-dev \
    autoconf \
    build-essential \
    bzip2 \
    curl \
    gdal-bin \
    git \
    libagg-dev \
    libboost-all-dev \
    libbz2-dev \
    libcairo2-dev \
    libcairomm-1.0-dev \
    libfreetype6-dev \
    libgdal-dev \
    libgeos-dev \
    libgeos++-dev \
    libicu-dev \
    liblua5.1-0-dev \
    liblua5.2-dev \
    libmapnik-dev \
    libpq-dev \
    libproj-dev \
    libtiff5-dev \
    libtool \
    libxml2-dev \
    lua5.1 \
    mapnik-utils \
    munin \
    munin-node \
    npm \
    osm2pgsql \
    postgis \
    postgresql \
    postgresql-12-postgis-3 \
    postgresql-12-postgis-3-scripts \
    postgresql-contrib \
    protobuf-c-compiler \
    python3-mapnik \
    python3-psycopg2 \
    python3-requests \
    python3-yaml \
    tar \
    ttf-unifont \
    unzip \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    # Install the legacy CartoCSS compiler package globally which is used to 
    # convert Carto-CSS stylesheets into something that mapnik can understand
    RUN npm install -g carto
    WORKDIR /app
    COPY scripts/setup_db.sh /app/scripts/setup_db.sh
    # Grant execution permissions to the script
    RUN chmod +x /app/scripts/setup_db.sh
    # Run the initialization script as the postgres user during build
    USER postgres
    RUN /app/scripts/setup_db.sh
    # Switch back to root for the remainder of the container setup
    USER root
    # Automatically creates the 'src' directory and navigates into it
    WORKDIR /src
    # Clone ONLY the v5.6.x branch into the current directory (.). This is the Stylesheet for map
    RUN git clone --single-branch --branch v5.6.x https://github.com/gravitystorm/openstreetmap-carto .
    # Compile the CartoCSS project file into a Mapnik XML stylesheet
    RUN carto project.mml > mapnik.xml
    COPY scripts/import_data.sh /app/scripts/import_data.sh
    RUN chmod +x /app/scripts/import_data.sh
    RUN /app/scripts/import_data.sh
    COPY scripts/map_scripts.sh /app/scripts/map_scripts.sh
    RUN chmod +x /app/scripts/map_scripts.sh
    # Change ownership of the directory to the postgres user
    # so the Python script directly without permission or role errors
    RUN chown -R postgres:postgres /app
    RUN chown -R postgres:postgres /src
    USER postgres
    RUN /app/scripts/map_scripts.sh
    # Tell the script to completely SKIP downloading Noto Emoji, but process all others
    RUN sed -i '/Noto Emoji/,/;;/d' scripts/get-fonts.sh \
        && chmod +x scripts/get-fonts.sh \
        && ./scripts/get-fonts.sh
    COPY --chown=postgres:postgres scripts/download_fonts.sh /app/scripts/download_fonts.sh
    RUN chmod +x /app/scripts/download_fonts.sh
    RUN /app/scripts/download_fonts.sh
    # Switch to root to create the system directory
    USER root
    RUN mkdir -p /home/postgres/osm/tiles && chown -R postgres:postgres /home/postgres
    # Switch back to postgres for the rest of the build
    USER postgres
    # Fix the HOME build variable so your Python script uses the correct directory
    ENV HOME=/home/postgres
    # Force-create the entire nested directory tree as the postgres user
    RUN mkdir -p /home/postgres/osm/tiles
    # The script that generates tiles (png) based on mapnik.xml  
    COPY --chown=postgres:postgres scripts/generate_tiles.py /app/scripts/generate_tiles.py
    # A simple wrapper to call the generate_tiles.py since it requires and active postgresql server
    COPY --chown=postgres:postgres scripts/generate_wrapper.sh /app/scripts/generate_wrapper.sh
    RUN chmod +x /app/scripts/generate_wrapper.sh
    RUN /app/scripts/generate_wrapper.sh
    # Switch back to root for administrative tasks
    USER root
    # Move the tiles to the Apache web root
    RUN mv /home/postgres/osm/tiles /var/www/html/tiles && \
        chown -R www-data:www-data /var/www/html/tiles
    # Copy the contents of the directory and not the directory itself
    COPY --chown=www-data:www-data ./data/ /var/www/html/
    # Expose port 80 to the host machine
    EXPOSE 80
    # Command to run Apache in the foreground, ensuring the container stays running
    CMD ["apache2ctl", "-D", "FOREGROUND"]