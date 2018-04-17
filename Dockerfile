FROM php:7.0-alpine

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN set -ex \
    && apk add --no-cache --virtual build-dependencies \
        autoconf \
        make \
        g++ \
        zlib

RUN docker-php-source extract \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) \
        sockets \
    && pecl install -o redis-4.0.0 && docker-php-ext-enable redis \
    && pecl install -o apcu-5.1.10 && docker-php-ext-enable apcu \
#    && pecl install -o memcached-3.0.4 && docker-php-ext-enable memcached \
    && pecl install -o xdebug-2.6.0 && docker-php-ext-enable xdebug \
#    && docker-php-source delete \
#    && rm -rf /usr/src/php* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

RUN apk add --no-cache libmemcached-dev zlib-dev cyrus-sasl-dev
RUN pecl install -o memcached-3.0.4 && docker-php-ext-enable memcached
RUN pecl install -o mongodb-1.4.2 && docker-php-ext-enable mongodb

RUN chmod go+x $(php -r "echo ini_get('extension_dir');")/*

RUN set -o pipefail && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /var/www
RUN chown -R www-data:www-data /var/www/
RUN chmod go+w /tmp
WORKDIR /var/www

ENV PATH /var/www/bin:/var/www/vendor/bin:${PATH}
CMD ["vendor/bin/phpunit"]

