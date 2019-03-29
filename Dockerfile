
FROM tutum/lamp


ARG MARIADB_HOST=localhost
ENV INT_MARIADB_HOST=$MARIADB_HOST

ARG limesurvey_DATABASE_USER="root"
ENV INT_limesurvey_DATABASE_USER=$limesurvey_DATABASE_USER

ARG limesurvey_DATABASE_PASSWORD=""
ENV INT_limesurvey_DATABASE_PASSWORD=$limesurvey_DATABASE_PASSWORD

ARG limesurvey_DATABASE_NAME="limesurvey"
ENV INT_limesurvey_DATABASE_NAME=$limesurvey_DATABASE_NAME

ARG limesurvey_USERNAME="admin"
ENV INT_limesurvey_USERNAME=$limesurvey_USERNAME

ARG limesurvey_PASSWORD="password"
ENV INT_limesurvey_PASSWORD=$limesurvey_PASSWORD

ARG limesurvey_FIRST_NAME="Admin"
ENV INT_limesurvey_FIRST_NAME=$limesurvey_FIRST_NAME

ARG limesurvey_EMAIL="admin@example.com"
ENV INT_limesurvey_EMAIL=$limesurvey_EMAIL

RUN echo $INT_MARIADB_HOST $INT_limesurvey_DATABASE_USER $INT_limesurvey_DATABASE_PASSWORD $INT_limesurvey_USERNAME $INT_limesurvey_PASSWORD $INT_limesurvey_FIRST_NAME $INT_limesurvey_EMAIL
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

RUN sed -i "s/host=localhost/host=$INT_MARIADB_HOST/" /app/application/config/config.php
RUN sed -i "s/dbname=limesurvey/dbname=$INT_MARIADB_DATABASE_NAME/" /app/application/config/config.php
RUN sed -i "s/'username' => 'root'/'username' => '$INT_limesurvey_DATABASE_USER'/" /app/application/config/config.php
RUN sed -i "s/'password' => ''/'password' => '$INT_limesurvey_DATABASE_PASSWORD'/" /app/application/config/config.php

ADD start.sh /
ADD run.sh /
ADD mysql-setup.sh ./
RUN sed -i 's/\. \/mysql-setup.sh/\. \/mysql-setup.sh $1 $2 $3 $4/' /create_mysql_admin_user.sh
RUN chmod +x /start.sh && \
    chmod +x /run.sh && \
    chmod +x /mysql-setup.sh

VOLUME /app/upload

EXPOSE 80 3306
RUN echo $INT_limesurvey_USERNAME $INT_limesurvey_PASSWORD $INT_limesurvey_FIRST_NAME $INT_limesurvey_EMAIL
CMD /start.sh $INT_limesurvey_USERNAME $INT_limesurvey_PASSWORD $INT_limesurvey_FIRST_NAME $INT_limesurvey_EMAIL $INT_limesurvey_DATABASE_NAME
