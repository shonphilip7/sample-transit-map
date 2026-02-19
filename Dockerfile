# Use the official Ubuntu base image
FROM ubuntu:latest
# Set environment variable to avoid interactive prompts during installation
ARG DEBIAN_FRONTEND=noninteractive
# Update the package list and install Apache2, then clean up apt cache
RUN apt-get update && apt-get install -y apache2 && apt-get clean
# Copy pre-generated map tiles directory to Apache root directory
# Copying zoom levels individually as the tiles directory is too large 
COPY tiles/9 /var/www/html/tiles/9
COPY tiles/10 /var/www/html/tiles/10
COPY tiles/11 /var/www/html/tiles/11
COPY tiles/12 /var/www/html/tiles/12
COPY tiles/13 /var/www/html/tiles/13
COPY tiles/14 /var/www/html/tiles/14
COPY tiles/15 /var/www/html/tiles/15
COPY map.html /var/www/html/
COPY R1_1.json /var/www/html/
# Expose port 80 to the host machine
EXPOSE 80
# Command to run Apache in the foreground, ensuring the container stays running
CMD ["apache2ctl", "-D", "FOREGROUND"]