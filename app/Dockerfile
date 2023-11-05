# Use Ubuntu as the base image
FROM ubuntu:latest

WORKDIR /opt/php-app

COPY . .

RUN apt-get update -y

RUN apt-get install software-properties-common -y

RUN add-apt-repository -y ppa:ondrej/php 

# Install Nginx and PHP 7.4
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php7.4 && \
   apt-get clean


# Nginx config
COPY conf/nginx /etc/nginx

RUN service nginx start 
# Configure PHP-FPM to run as a daemon
#RUN echo "daemon off;" >> /etc/php/7.4/fpm/php-fpm.conf

# Copy Nginx and PHP configurations
#COPY web-conf/nginx.conf /etc/nginx/
#COPY web-conf/php.ini /etc/php/7.4/fpm/php.ini

# Expose ports
EXPOSE 8080


# Start Nginx and PHP-FPM
#CMD ["service nginx start"]
#CMD ["nginx", "-g", "daemon off;"]
#ENTRYPOINT ["/start.sh"]
CMD php -S 0.0.0.0:8080
