FROM ubuntu:22.04
LABEL likelion.web.backendauthor="Ivan Kim <xormrdlsrks2@gmail.com>"

RUN apt-get update
RUN apt-get install -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

VOLUME [ "/data", "/etc/nginx/sites-enabled", "/var/log/nginx" ]

WORKDIR /etc/nginx

CMD [ "nginx" ]

EXPOSE 80
EXPOSE 443

