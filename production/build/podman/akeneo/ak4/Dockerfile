FROM debian:stretch-slim

ENV DEBIAN_FRONTEND="noninteractive" \ 
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux" \
    HOME="/build" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    LANG="en_US.UTF-8" \
    TERM="xterm"

RUN apt-get update && \
    echo "**** install useful distro packages ****" && \
    apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
        apt-transport-https \
        lsb-release \
        ca-certificates \
        bash-completion \
        gnupg \
        procps \
        wget \
        curl \
        less \
        make \
        ssh-client \
        vim \
        nano \
        ghostscript \
        unzip \
        cron \
        systemd-sysv \
        perceptualdiff && \
    apt-get clean && apt-get --yes --quiet autoremove --purge && \
    rm -rf  /var/lib/apt/lists/* /tmp/* /var/tmp/* \
            /usr/share/doc/* /usr/share/groff/* /usr/share/info/* /usr/share/linda/* \
            /usr/share/lintian/* /usr/share/locale/* /usr/share/man/*

# Add Sury PHP repository
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
COPY files/sury.list /etc/apt/sources.list.d/sury.list

# install app dependencies with extensions
RUN apt-get update && \
    apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
        imagemagick \
        nginx \
        php7.3-cli \
        php7.3-apcu \
        php7.3-mbstring \
        php7.3-curl \
        php7.3-gd \
        php7.3-imagick \
        php7.3-intl php7.3-bcmath \
        php7.3-mysql \
        php7.3-xml \
        php7.3-fpm \
        php7.3-zip \
        php7.3-ldap && \
    apt-get clean && apt-get --yes --quiet autoremove --purge && \
    rm -rf  /var/lib/apt/lists/* /tmp/* /var/tmp/* \
            /usr/share/doc/* /usr/share/groff/* /usr/share/info/* /usr/share/linda/* \
            /usr/share/lintian/* /usr/share/locale/* /usr/share/man/*

# create a build user and home-directory, setup a app directory
RUN useradd -u 911 -U -d /build -s /bin/bash build && \
    usermod -G users build && \
    mkdir -p \
	/build/app && \
    chown build:www-data /build/app

COPY files/php/app.ini /etc/php/7.3/mods-available/app.ini
RUN phpenmod app
COPY --chown=build:www-data app /build/app
COPY files/nginx /etc/nginx/sites-available/
COPY files/entrypoint.sh /etc/entrypoint.sh
RUN rm /etc/nginx/sites-enabled/default; ln -s /etc/nginx/sites-available/prod.conf /etc/nginx/sites-enabled/prod.conf

EXPOSE 80
EXPOSE 22

RUN systemctl enable php7.3-fpm; systemctl enable nginx

CMD [ "/sbin/init" ]
