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
ADD etc/vhost/* /etc/nginx/vhost/
ADD etc/conf.d/* /etc/nginx/conf.d/
RUN rm -f /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/www
RUN mkdir -p /var/lib/nginx/cache

EXPOSE 80
# EXPOSE 443

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#CMD ["run"]