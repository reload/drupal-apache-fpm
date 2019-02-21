FROM phusion/baseimage:0.11

# Basic install of apache
RUN install_clean apache2 ssl-cert

# Add custom apache configuration and prepare services.
COPY files/etc/ /etc/

# Switch docroot from html to web to be docker-compose compatible
RUN \
  mv /var/www/html /var/www/web

# Enable needed apache modules and configuration added above
RUN \
  a2enmod rewrite && \
  a2enmod proxy_fcgi && \
  a2enmod remoteip && \
  a2enmod expires && \
  a2enmod ssl && \
  a2ensite ssl && \
  a2enconf allow-override-all && \
  a2enconf php-fpm

RUN \
  mkdir /cert && \
  mkdir /mkcert && \
  curl -sSL https://github.com/FiloSottile/mkcert/releases/download/v1.3.0/mkcert-v1.3.0-linux-amd64 -o /usr/local/bin/mkcert && \
  chmod +x /usr/local/bin/mkcert

EXPOSE 80
EXPOSE 443
