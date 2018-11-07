#!/bin/bash

docker stop wordpress
docker rm wordpress

docker run \
--name wordpress \
--restart=always \
-v /etc/localtime:/etc/localtime:ro \
-e WORDPRESS_DB_HOST= "ENDPOINT-OF-DB" \
-e WORDPRESS_DB_USER= "USERNAME-OF-DB" \
-e WORDPRESS_DB_PASSWORD= "PASSWORD-OF-DB" \
-p 8080:80 \
-d  wordpress:4.9.8-php5.6-apache
