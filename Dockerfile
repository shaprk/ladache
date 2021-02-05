FROM php:7.4.14-apache

WORKDIR /var/www

RUN apt-get update \
    && apt-get install -y gnupg tzdata \
    && echo "UTC" >> /etc/timezone \
    && dpkg-reconfigure -f nonintractive tzdata \
    && apt-get install -y curl zip unzip git supervisor sqlite3

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV APACHE_DOCUMENT_ROOT /var/www/public

ADD ./apache.conf /etc/apache2/apache.conf

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && chown -R www-data:www-data /var/www && a2enmod rewrite

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions gd imagick bz2 mysqli \
    pdo_mysql gettext gmp intl imap ldap exif pgsql \
    pdo_odbc pdo_pgsql shmop memcached redis tidy xsl xdebug
