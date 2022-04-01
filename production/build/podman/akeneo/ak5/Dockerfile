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
        htop \
        ssh-client \
        vim \
        nano \
        aspell \
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

# for mysql-client to work properly we need to add the mysql-apt-config package

# install app dependencies with extensions
RUN apt-get update && \
    apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
        imagemagick \
        nginx \
        mysql-client \
        php7.4-cli \
        php7.4-apcu \
        php7.4-mbstring \
        php7.4-curl \
        php7.4-gd \
        php7.4-imagick \
        php7.4-intl php7.4-bcmath \
        php7.4-mysql \
        php7.4-xml \
        php7.4-fpm \
        php7.4-zip \
        php7.4-ldap && \
    apt-get clean && apt-get --yes --quiet autoremove --purge && \
    rm -rf  /var/lib/apt/lists/* /tmp/* /var/tmp/* \
            /usr/share/doc/* /usr/share/groff/* /usr/share/info/* /usr/share/linda/* \
            /usr/share/lintian/* /usr/share/locale/* /usr/share/man/*

# create a build user and home-directory, setup a app directory
RUN useradd -u 911 -U -d /build -s /bin/bash build && \
    usermod -G users build && \
    mkdir -p \
	/build/app && \
    chown build:www-data /build -R

COPY files/php/app.conf /etc/php/7.4/fpm/pool.d/
COPY files/php/app.ini /etc/php/7.4/mods-available/app.ini
COPY files/php/cli-conf.ini /etc/php/7.4/cli/conf.d/99-pim.ini
COPY files/php/fpm-conf.ini /etc/php/7.4/fpm/conf.d/99-pim.ini
RUN rm /etc/php/7.4/fpm/pool.d/www.conf && phpenmod app

RUN phpenmod app
COPY --chown=build:www-data app /build/app
COPY files/nginx /etc/nginx/sites-available/
RUN rm /etc/nginx/sites-enabled/default; ln -s /etc/nginx/sites-available/prod.conf /etc/nginx/sites-enabled/prod.conf

# cron & cron wrapper
USER build
COPY files/scripts/cron_wrapper.sh /build/scripts/cron_wrapper.sh
COPY files/ak5.crons /build/scripts/cronfile
RUN crontab /build/scripts/cronfile

USER root

# pim_job_queue
RUN mkdir -p /build/.config/systemd/user/
COPY files/queue/pim_job_queue.service /etc/systemd/system/pim_job_queue@.service

EXPOSE 80

RUN systemctl enable php7.4-fpm; systemctl enable nginx; systemctl enable pim_job_queue@1.service

CMD [ "/sbin/init" ]
