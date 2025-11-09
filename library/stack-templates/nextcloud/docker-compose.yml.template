services:
  db:
    image: mariadb:10.11
    container_name: nextcloud_db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_PASSWORD: secret
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      
    volumes:
      - {$VOLUMES_DIR}/nextcloud_db:/var/lib/mysql

    networks:
      - minicloud

  app:
    image: nextcloud:latest
    container_name: nextcloud_app
    restart: unless-stopped
    environment:
      MYSQL_PASSWORD: secret
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_HOST: db

    volumes:
      - {$VOLUMES_DIR}/nextcloud_data:/var/www/html

    networks:
      - minicloud

networks:
  minicloud:
    external: true
