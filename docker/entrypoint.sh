#! /bin/bash
set -e

: ${MYSQL_USER:=root}
: ${MYSQL_PASS:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
: ${MYSQL_HOST:=mysql}
: ${USER:=maptool}

while ! mysqladmin ping -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" --silent; do
    echo "Waiting for mysql container..."
    sleep 1
done

if ! mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "use evewspace" --silent; then
        echo "Creating evewspace database"
        mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "CREATE DATABASE evewspace CHARACTER SET utf8;"
        mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" evewspace < /home/$USER/evedump.sql

        echo "Running evewspace setup"
        source /evewspace.sh
fi

/usr/bin/supervisord