FROM alpine:3.7

VOLUME ["/DATA"]

# hadolint ignore=DL3018
RUN echo 'http://dl-4.alpinelinux.org/alpine/latest-stable/main/' >> /etc/apk/repositories\
    && apk update \
    && apk add --no-cache \
    bash \
    less \
    nano \
    sudo \
    shadow \
    nginx \
    ca-certificates \
    php7-fpm \
    php7-zip \
    php7-tokenizer \
    php7-json \
    php7-redis \
    php7-zlib \
    php7-xml \
    php7-pdo \
    php7-phar \
    php7-openssl \
    php7-pdo_mysql \
    php7-mysqli \
    php7-session \
    php7-gd \
    php7-iconv \
    php7-mcrypt \
    php7-curl \
    php7-opcache \
    php7-ctype \
    php7-apcu \
    php7-intl \
    php7-bcmath \
    php7-mbstring \
    php7-dom \
    php7-xmlreader \
    php7-simplexml \
    mysql-client \
    openssh-client \
    git \
    curl \
    rsync \
    musl \
    && apk --update --no-cache add tar
RUN rm -rf /var/cache/apk/*


ENV PATH /DATA/bin:$PATH

RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php7/php.ini && \
    sed -i "s/nginx:x:100:101:nginx:\\/var\\/lib\\/nginx:\\/sbin\\/nologin/nginx:x:100:101:nginx:\\/DATA:\\/bin\\/bash/g" /etc/passwd && \
    sed -i "s/nginx:x:100:101:nginx:\\/var\\/lib\\/nginx:\\/sbin\\/nologin/nginx:x:100:101:nginx:\\/DATA:\\/bin\\/bash/g" /etc/passwd-


COPY files/nginx.conf /etc/nginx/
COPY files/php-fpm.conf /etc/php7/
COPY files/run.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN curl -O -L https://github.com/wp-cli/wp-cli/releases/download/v2.0.0/wp-cli-2.0.0.phar && mv wp-cli-2.0.0.phar wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp && chown nginx:nginx /usr/bin/wp

ENV WORDPRESS_VERSION 4.9.8
ENV WORDPRESS_SHA1 0945bab959cba127531dceb2c4fed81770812b4f

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
	tar -xzf wordpress.tar.gz -C /home/; \
	rm wordpress.tar.gz; \
	chown -R nginx:nginx /home/

WORKDIR /var/www/html

RUN tar --create \
        --file - \
        --one-file-system \
        --directory /home/wordpress \
        --owner "nginx" --group "nginx" \
        . | tar --extract --file -

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]