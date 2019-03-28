
FROM tutum/lamp


ARG MARIADB_HOST=localhost
ENV env_var_name=$MARIADB_HOST

ARG limesurvey_DATABASE_USER="root"
ENV env_var_name=$limesurvey_DATABASE_USER

ARG limesurvey_DATABASE_PASSWORD=""
ENV env_var_name=$limesurvey_DATABASE_PASSWORD

ARG limesurvey_USERNAME="admin"
ENV env_var_name=$limesurvey_USERNAME

ARG limesurvey_PASSWORD="password"
ENV env_var_name=$limesurvey_PASSWORD

ARG limesurvey_FIRST_NAME="Admin"
ENV env_var_name=$limesurvey_FIRST_NAME

ARG limesurvey_EMAIL="admin@example.com"
ENV env_var_name=$limesurvey_EMAIL

RUN echo $MARIADB_HOST $limesurvey_DATABASE_USER $limesurvey_DATABASE_PASSWORD $limesurvey_USERNAME $limesurvey_PASSWORD $limesurvey_FIRST_NAME $limesurvey_EMAIL
RUN apt-get update && \
	apt-get upgrade -q -y && \
	apt-get install -q -y curl php5-gd php5-ldap php5-imap sendmail php5-pgsql php5-curl && \
	apt-get clean && \
	php5enmod imap

RUN rm -rf /app
ADD limesurvey.tar.bz2 /
RUN mv limesurvey app; \
	mkdir -p /uploadstruct; \
	chown -R www-data:www-data /app

RUN cp -r /app/upload/* /uploadstruct ; \
	chown -R www-data:www-data /uploadstruct

RUN chown www-data:www-data /var/lib/php5

ADD apache_default /etc/apache2/sites-available/000-default.conf
ADD config.php /app/application/config/
RUN chown www-data:www-data /app/application/config/config.php

RUN sed -i "s/host=localhost/host=$MARIADB_HOST/" /app/application/config/config.php
RUN sed -i "s/'username' => 'root'/'username' => '$limesurvey_DATABASE_USER'/" /app/application/config/config.php
RUN sed -i "s/'password' => ''/'password' => '$limesurvey_DATABASE_PASSWORD'/" /app/application/config/config.php

RUN cd /app/application/commands/ && ls -l
RUN cd /app/application/commands/ && /usr/bin/php console.php install $limesurvey_USERNAME $limesurvey_PASSWORD $limesurvey_FIRST_NAME $limesurvey_EMAIL

ADD start.sh /
ADD run.sh /
ADD mysql-setup.sh ./


RUN chmod +x /start.sh && \
    chmod +x /run.sh && \
    chmod +x /mysql-setup.sh

VOLUME /app/upload

EXPOSE 80 3306
CMD ["/start.sh"]
