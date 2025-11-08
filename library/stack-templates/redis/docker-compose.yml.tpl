services:
  redis:
    image: redis:7
    container_name: redis
    restart: unless-stopped
    environment:
      REDIS_PASSWORD: "minicloud"

    command: ["redis-server", "--requirepass", "minicloud"]
    networks:
      - minicloud

networks:
  minicloud:
    external: true
