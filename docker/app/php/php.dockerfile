FROM php:8.3-fpm
ENV WEB_DOCUMENT_ROOT=/app/public
ENV COMPOSER_ALLOW_SUPERUSER=1
#ENV GITHUB_OAUTH=
# ARG would allow passing in from external env
# ARG GITHUB_OAUTH

# install system updates
RUN apt-get update


RUN apt-get install -y default-jre procps htop vim zip unzip libzip-dev libicu-dev libpq-dev libpng-dev git curl
RUN NODE_MAJOR=20 apt-get install -y nodejs npm;

# install php docker extensions
RUN \
  docker-php-ext-configure intl && \
  docker-php-ext-install intl pcntl zip pdo pdo_pgsql gd opcache exif

# Get latest Composer
COPY --from=composer:2.6.6 /usr/bin/composer /usr/bin/composer
# if needing to pass in github oauth
#RUN composer config -g github-oauth.github.com $GITHUB_OAUTH


RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

COPY ./ /app
COPY ./docker/app/php/99-local.ini /usr/local/etc/php/conf.d/99-local.ini
COPY --chmod=744 ./docker/app/php/prepare_app.sh /app/prepare_app.sh


RUN curl https://frankenphp.dev/install.sh | sh \
    && mv frankenphp /usr/local/bin/

WORKDIR /app

RUN mkdir -p storage storage/framework storage/framework/cache storage/framework/sessions storage/framework/testing storage/framework/views storage/logs;
RUN composer install;

EXPOSE 80
