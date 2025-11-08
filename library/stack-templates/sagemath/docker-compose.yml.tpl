services:
  sagemath:
    image: sagemath/sagemath:latest
    container_name: sagemath
    restart: unless-stopped
    ports:
      - "8889:8888" # optional, mapped for testing

    networks:
      - minicloud

networks:
  minicloud:
    external: true
