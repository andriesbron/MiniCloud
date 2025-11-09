services:
  jupyter:
    image: jupyter/base-notebook:latest
    container_name: jupyter
    restart: unless-stopped
    environment:
      JUPYTER_TOKEN: "minicloud"
    ports:
      - "8888:8888" # optional, Caddy will handle subdomain
    volumes:
      - {$VOLUMES_DIR}/jupyter_data:/home/jovyan/work
    networks:
      - minicloud

networks:
  minicloud:
    external: true
