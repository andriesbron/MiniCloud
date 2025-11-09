# See container logs for user name and first password.
services:
  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser
    ports:
      - "9080:80"
    environment:
      - PUID=1000         # change to host user id
      - PGID=1000         # change to host group id
      - TZ=Europe/Amsterdam
    volumes:
      - {$VOLUMES_DIR}/filebrowser-srv:/srv   # root folder to browse
      - {$VOLUMES_DIR}/filebrowser-db:/database.db
      - {$VOLUMES_DIR}/filebrowser/config:/config
    restart: unless-stopped

networks:
 minicloud:
   external: true
