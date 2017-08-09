FROM nginx:latest

MAINTAINER Lyberteam <lyberteamltd@gmail.com>

LABEL Vendor="lyberteam"
LABEL Description="This is a base nginx image from the official Nginx image "
LABEL version="1.0.1"

RUN apt-get update && apt-get install -y \
    mc \
    nano

RUN usermod -u 1000 www-data

RUN mkdir -p /etc/service/nginx
ADD run.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

ADD etc/* /etc/nginx/
ADD etc/conf.d/upstream.conf /etc/nginx/conf.d/upstream.conf
ADD etc/vhost/lyberteam.conf /etc/nginx/vhost/lyberteam.conf

RUN mkdir -p /var/www
RUN mkdir -p /var/lib/nginx/cache

EXPOSE 80
# EXPOSE 443

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/etc/service/nginx/run"]