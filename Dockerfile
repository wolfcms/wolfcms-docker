FROM ubuntu:14.04.1
MAINTAINER Martijn <martijn.niji@gmail.com>

RUN apt-get -qq update

RUN apt-get install -y \
		apache2 \
		curl \
		php5-curl \
		php5-mysql \
                php5 \
		wget \
                unzip \
	&& rm -rf /var/lib/apt/lists/*
RUN a2enmod rewrite

# copy a few things from apache's init script that it requires to be setup
ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars
# and then a few more from $APACHE_CONFDIR/envvars itself
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE $APACHE_RUN_DIR/apache2.pid
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

# make CustomLog (access log) go to stdout instead of files
#  and ErrorLog to stderr
RUN find "$APACHE_CONFDIR" -type f -exec sed -ri ' \
	s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
	s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
' '{}' ';'

RUN rm -rf /var/www/html && mkdir /var/www/html
VOLUME /var/www/html
WORKDIR /var/www/html

ENV WOLFCMS_VERSION 080

# upstream tarballs include ./wolfcms/ so this gives us /usr/src/wolfcms
#RUN curl -SL https://bitbucket.org/wolfcms/wolf-cms-downloads/downloads/wolfcms_$WOLFCMS_VERSION.zip | unzip -d /usr/src/

COPY docker-apache.conf /etc/apache2/sites-available/wolfcms.conf
RUN a2dissite 000-default && a2ensite wolfcms

#COPY docker-entrypoint.sh /entrypoint.sh

#ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80
CMD ["apache2", "-DFOREGROUND"]
