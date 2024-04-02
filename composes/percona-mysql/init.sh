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

LOCK_FILE="/tmp/setup-percona-mysql.lock"

function setup() {
    OPENSSL=$(which openssl)
    MYSQL_PORT=$mysqlPort
    MYSQL_ROOT_PASSWORD=$($OPENSSL rand -hex 16)
    MYSQL_DATABASE=$(echo -e "percona_db_$($OPENSSL rand -hex 2)")
    MYSQL_USER=$(echo -e "percona_usr_$($OPENSSL rand -hex 2)")
    MYSQL_PASSWORD=$($OPENSSL rand -hex 16)

    if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
        PMA_PORT=$pmaPort

        if [[ ! -f docker-compose.yml ]]; then
            $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/percona-mysql/docker-compose-with-phpmyadmin.yml
        fi
    else
        if [[ ! -f docker-compose.yml ]]; then
            $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/percona-mysql/docker-compose-without-phpmyadmin.yml
        fi
    fi

    if [[ ! -f start.sh ]]; then
        $(which wget) https://raw.githubusercontent.com/mindevis/scripts/main/composes/percona-mysql/start.sh
        $(which chmod) +x start.sh
    fi

    if [[ ! -f stop.sh ]]; then
        $(which wget) https://raw.githubusercontent.com/mindevis/scripts/main/composes/percona-mysql/stop.sh
        $(which chmod) +x stop.sh
    fi

    if [[ ! -f restart.sh ]]; then
        $(which wget) https://raw.githubusercontent.com/mindevis/scripts/main/composes/percona-mysql/restart.sh
        $(which chmod) +x restart.sh
    fi

    echo -e "${WARN}Initialization database configuration for MySQL.${NORMAL}"
    echo -e "${WARN}Backup database configuration file.${NORMAL}"
    $(which cp) docker-compose.yml{,.bak}
    echo -e "${WARN}Setup MySQL version to ${mysqlVersion}.${NORMAL}"
    $(which sed) -i "s/MYSQLVERSION/$mysqlVersion/g" docker-compose.yml
    echo -e "${WARN}Change default MySQL exposed port.${NORMAL}"
    $(which sed) -i "s/MYSQLPORT/$MYSQL_PORT/g" docker-compose.yml
    if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
        echo -e "${WARN}Change default phpmyadmin exposed port.${NORMAL}"
        $(which sed) -i "s/PMAPORT/$PMA_PORT/g" docker-compose.yml
    fi
    echo -e "${WARN}Generate MySQL root password.${NORMAL}"
    $(which sed) -i "s/MYSQLROOTPASSWORD/$MYSQL_ROOT_PASSWORD/g" docker-compose.yml
    echo -e "${WARN}Generate MySQL database.${NORMAL}"
    $(which sed) -i "s/MYSQLDATABASE/$MYSQL_DATABASE/g" docker-compose.yml
    echo -e "${WARN}Generate MySQL user.${NORMAL}"
    $(which sed) -i "s/MYSQLUSER/$MYSQL_USER/g" docker-compose.yml
    echo -e "${WARN}Generate MySQL user password.${NORMAL}"
    $(which sed) -i "s/MYSQLPASSWORD/$MYSQL_PASSWORD/g" docker-compose.yml

    echo -e "${WARN}Start Percona MySQL environment.${NORMAL}"
    $(which docker) compose up -d

    rm -f "$LOCK_FILE"
    rm -f "$0"
}

# Entrypoint to script
case "$1" in
    --setup)
        count=1
        for arguments in "$@"; do
            if [[ "$arguments" = "--version" ]]; then
                mysqlVersion="$2"
            fi

            if [[ "$arguments" = "--mysql-port" ]]; then
                mysqlPort="$2"
            fi

            if [[ "$arguments" = "--pma-enable" ]]; then
                pmaEnable="$2"
            fi

            if [[ "$arguments" = "--pma-port" ]]; then
                pmaPort="$2"
            fi

            count=$(( "$count" + 1 ))
            shift
        done

        if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
            if [[ -z $mysqlVersion ]] || [[ -z $mysqlPort ]] || [[ -z $pmaPort ]]; then
                echo -e "${WARN}You have not specified all required arguments.${NORMAL}"
                exit 1
            fi
        else
            if [[ -z $mysqlVersion ]] || [[ -z $mysqlPort ]]; then
                echo -e "${WARN}You have not specified all required arguments.${NORMAL}"
                exit 1
            fi
        fi

        $(which touch) $LOCK_FILE
        setup
esac