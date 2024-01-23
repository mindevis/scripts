#!/usr/bin/env bash
if  [ "$TERM" = "linux" ] || [ "$TERM" = "xterm" ] || [ "$TERM" = "xterm-color" ] || [ "$TERM" = "screen" ] && [ "$USE_COLORS" = "1" ]; then
    GOOD=$'\e[32;01m'
    WARN=$'\e[33;01m'
    BAD=$'\e[31;01m'
    NORMAL=$'\e[0m'
    HILITE=$'\e[37;01m'
    BRACKET=$'\e[34;01m'
else
    GOOD=$'\e[0;32m'
    BAD=$'\e[0;31m'
    NORMAL=$'\e[0m'
    WARN=$'\e[0;33m'
    HILITE='\033[1;37m'
    BRACKET=${NORMAL}
fi

OPENSSL=$(which openssl)
MYSQL_PORT=$1
PMA_PORT=$2
MYSQL_ROOT_PASSWORD=$($OPENSSL rand -hex 16)
MYSQL_DATABASE=$(echo -e "percona_db_$($OPENSSL rand -hex 2)")
MYSQL_USER=$(echo -e "percona_usr_$($OPENSSL rand -hex 2)")
MYSQL_PASSWORD=$($OPENSSL rand -hex 16)

echo -e "${WARN}Initialization database configuration for MySQL.${NORMAL}"
echo -e "${WARN}Backup database configuration file.${NORMAL}"
cp docker-compose.yml{,.bak}
echo -e "${WARN}Change default MySQL exposed port.${NORMAL}"
sed -i "s/MYSQLPORT/$MYSQL_PORT/g" docker-compose.yml
echo -e "${WARN}Change default phpmyadmin exposed port.${NORMAL}"
sed -i "s/PMAPORT/$PMA_PORT/g" docker-compose.yml
echo -e "${WARN}Generate MySQL root password.${NORMAL}"
sed -i "s/MYSQLROOTPASSWORD/$MYSQL_ROOT_PASSWORD/g" docker-compose.yml
echo -e "${WARN}Generate MySQL database.${NORMAL}"
sed -i "s/MYSQLDATABASE/$MYSQL_DATABASE/g" docker-compose.yml
echo -e "${WARN}Generate MySQL user.${NORMAL}"
sed -i "s/MYSQLUSER/$MYSQL_USER/g" docker-compose.yml
echo -e "${WARN}Generate MySQL user password.${NORMAL}"
sed -i "s/MYSQLPASSWORD/$MYSQL_PASSWORD/g" docker-compose.yml

echo -e "${WARN}Start environment.${NORMAL}"
docker compose up -d