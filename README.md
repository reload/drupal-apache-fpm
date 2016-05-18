# Apache FPM container based on phusion
Simple apache-vhost that serves content from /var/www/web - php-requests are
proxied to a linked fpm-container named "fpm" on port 9000.
