
FROM ubuntu

RUN apt-get update && \
	apt-get upgrade -q -y && \
	apt-get install -q -y php curl php-gd php-ldap php-imap sendmail php-pgsql php-curl && \
	apt-get clean && \
	phpenmod imap

RUN rm -rf /app
ADD limesurvey.tar.bz2 /
RUN mv limesurvey app; \
	mkdir -p /uploadstruct; \
	chown -R www-data:www-data /app

RUN cp -r /app/upload/* /uploadstruct ; \
	chown -R www-data:www-data /uploadstruct

RUN chown www-data:www-data /var/lib/php

ADD apache_default /etc/apache2/sites-available/000-default.conf
ADD start.sh /
ADD run.sh /

RUN chmod +x /start.sh && \
    chmod +x /run.sh

VOLUME /app/upload

EXPOSE 80
CMD ["/start.sh"]
