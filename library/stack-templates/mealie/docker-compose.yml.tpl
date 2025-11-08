services:
  mealie:
    image: ghcr.io/mealie-recipes/mealie:v1.5.1
    container_name: mealie
    restart: unless-stopped
    ports:
      - "9925:9000"
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
      - BASE_URL=http://localhost:9925
      - DB_ENGINE=postgres
      - POSTGRES_SERVER=postgres
      - POSTGRES_PORT=5432
      - POSTGRES_USER=mealie
      - POSTGRES_PASSWORD=mealiepassword
      - POSTGRES_DB=mealie
    volumes:
      - {$VOLUMES_DIR}/mealie-data:/app/data

  postgres:
    image: postgres:15
    container_name: mealie-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=mealie
      - POSTGRES_PASSWORD=mealiepassword
      - POSTGRES_DB=mealie
    volumes:
      - {$VOLUMES_DIR}/mealie-postgres-data:/var/lib/postgresql/data

networks:
 minicloud:
   external: true  
