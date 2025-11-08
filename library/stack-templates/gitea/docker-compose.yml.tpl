services:
  gitea:
    image: gitea/gitea:latest
    container_name: gitea
    restart: unless-stopped
    environment:
      USER_UID: 1000
      USER_GID: 1000
      GITEA__database__DB_TYPE: sqlite3
    volumes:
      - {$VOLUMES_DIR}/gitea-data:/data
    networks:
      - minicloud

networks:
  minicloud:
    external: true
