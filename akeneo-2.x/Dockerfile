FROM akeneo/fpm:php-7.1

RUN apt-get update && \
    apt-get --no-install-recommends --no-install-suggests --yes --quiet install apache2 libapache2-mod-php7.1 && \
    apt-get clean && apt-get --yes --quiet autoremove --purge && \
    rm -rf  /var/lib/apt/lists/* /tmp/* /var/tmp/* \
            /usr/share/doc/* /usr/share/groff/* /usr/share/info/* /usr/share/linda/* \
            /usr/share/lintian/* /usr/share/locale/* /usr/share/man/*

# Configure PHP Apache
RUN phpenmod akeneo && phpdismod xdebug && \
    rm -f /etc/apache2/sites-enabled/000-default.conf && \
    rm -f /etc/apache2/sites-enabled/default-ssl.conf && \
    a2enmod rewrite headers auth_basic proxy_fcgi setenvif && \
    a2enconf php7.1-fpm && \
    systemctl reload apache2

# Expose Apache
EXPOSE 80 443

# @TODO link a vhost file

RUN a2ensite akeneo.conf && \
    systemctl restart php7.1-fpm && \
    systemctl reload apache2

# set php to the foreground
CMD ["sudo", "php-fpm7.1", "-F"]
