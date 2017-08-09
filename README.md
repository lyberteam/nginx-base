# Project Title

This is a bse nginx image made to work with php-fpm.

## Getting Started
If you want to use Nginx with PHP-FPM - you can read more here

### Running in docker-compose (for ubuntu)

```
## /path_to_project_root/docker-compose.yml

nginx:
  restart: always
  image: lyberteam/nginx-base
  ports:
     - "80:80"
  working_dir: /etc/nginx/vhost
  ## just in case you want to use php-fpm container you should use links
  links:
     - php
  volumes:
     - /path_to_yor_folder/nginx/logs:/var/log/nginx
     - /path_to_yor_folder/nginx/nginx.conf:/etc/nginx/nginx.conf
     - /path_to_yor_folder/nginx/conf.d/upstream.conf:/etc/nginx/conf.d/upstream.conf
     - /path_to_yor_folder/nginx/vhost/lyberteam.conf:/etc/nginx/vhost/lyberteam.conf

php:
  restart: always
  image: lyberteam/php-fpm7.0:xtools
  volume:
      - /path_to_project_root:/var/www/lyberteam
  working_dir: /var/www/lyberteam
```

 * upstream.conf - is a link between you nginx file and php container:
here we have php container with name php and exposed port in thous container - 9000.
```
upstream php-upstream {
    server php:9000;
}
```

 * nginx.conf:

```
user www-data;
worker_processes  auto;

pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    include       /etc/nginx/proxy_params;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    sendfile on;
    types_hash_max_size 2048;
    server_tokens off;
    tcp_nodelay on;
    keepalive_timeout 30;
    tcp_nopush on;

    ##
    # SSL Settings
    ##

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##

    gzip on;
    gzip_disable "msie6";

    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 2;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

	open_file_cache max=200000 inactive=20s; # Sets maximum number of files in cache
    open_file_cache_valid 30s; # Sets cache ttl
    open_file_cache_min_uses 2; # Enables caching data for files that have been accessed at least 2 times
    open_file_cache_errors on; # Enables caching data about missing files

    limit_conn_zone $binary_remote_addr zone=perip:10m;
    limit_conn perip 100;

    fastcgi_cache_path /var/lib/nginx/cache/fastcgi levels=1:2 keys_zone=fastcgicache:50m inactive=60m;
    fastcgi_cache_key "$scheme$request_method$host$request_uri";

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/vhost/*.conf;
}
```

And the main file of your configuration:

```
server {
    server_name lyberteam.com;
    root /var/www/lyberteam/web;

    error_log /var/log/nginx/lyberteam_error.log;
    access_log /var/log/nginx/lyberteam_access.log;

    client_max_body_size 20M;

    location ~ /media/cache/ {
        try_files \$uri @rewriteapp;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)(\?v[0-9]+)?$ {
         expires 1y;
         add_header Vary Accept-Encoding;
         access_log off;
         log_not_found off;
    }

    location / {
        try_files $uri @rewriteapp;
    }

    location @rewriteapp {
        rewrite ^(.*)$ /index.php/$1 last;
    }

    location ~ ^/(index|app)\.php(/|$) {
        fastcgi_pass php-upstream;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTPS off;

        client_max_body_size 20M;
        client_body_buffer_size 20M;
        fastcgi_buffer_size   20M;
        fastcgi_buffers   4 20M;
        fastcgi_busy_buffers_size   20M;
    }
}
```

1. `server_name lyberteam.com;` - You should replace the server name by your own domain name
2. `root /var/www/lyberteam/web;` - You should write here the folder, where your index.php lies
3. `fastcgi_pass php-upstream;`  - If you have a local php you can replace this line with
    * php5 - fastcgi_pass unix:/var/run/php5-fpm.sock;
    * php7 - fastcgi_pass unix:/run/php/php7.0-fpm.sock;
4. `rewrite ^(.*)$ /index.php/$1 last;` - This is rewrite rule. You can replace it with yours one
