FROM debian:buster

#ADD ALL CONF FILES
COPY srcs/* ./home/

#ADD ALL NEEDED APT
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install nginx
RUN apt-get -y install wget
RUN apt-get -y install mariadb-server
RUN apt-get -y install php php-mysql php-fpm php-cli php-mbstring php-zip php-gd

#CONF WORDPRESS
RUN wget https://wordpress.org/latest.tar.gz
RUN tar xvf latest.tar.gz
RUN rm -rf latest.tar.gz
RUN mv ./home/wp-config.php wordpress

#CONF PHPMyAdmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN tar xvf phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN rm -rf phpMyAdmin-4.9.0.1-all-languages.tar.gz

#CONF NGINX
RUN rm -rf /etc/nginx/sites-enabled/default
RUN cp ./home/nginx.conf /etc/nginx/sites-enabled/localhost

#CONF MARIADB
RUN bash ./home/mysql.sh

#SORT INDEX
RUN mv phpMyAdmin-4.9.0.1-all-languages/ /var/www/html/phpmyadmin
RUN mkdir /var/www/html/accueil
RUN mv /var/www/html/index.nginx-debian.html /var/www/html/accueil/
RUN mv wordpress /var/www/html

#CERTIFICATION SSL
RUN wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.3.0/mkcert-v1.3.0-linux-amd64
RUN chmod +x mkcert
RUN mv mkcert /usr/local/bin
RUN mkcert -install
RUN mkcert localhost
RUN mv localhost.pem /etc/nginx/
RUN mv localhost-key.pem /etc/nginx/

#LANCEMENT && BOUCLE
CMD bash ./home/start.sh

EXPOSE 80 443
