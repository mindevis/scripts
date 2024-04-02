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

LOCK_FILE="/tmp/setup-mysql.lock"

function setup() {
    OPENSSL=$(which openssl)
    MYSQL_PORT=$mysqlPort
    MYSQL_ROOT_PASSWORD=$($OPENSSL rand -hex 16)
    MYSQL_DATABASE=$(echo -e "db_$($OPENSSL rand -hex 4)")
    MYSQL_USER=$(echo -e "usr_$($OPENSSL rand -hex 4)")
    MYSQL_PASSWORD=$($OPENSSL rand -hex 16)

    if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
        PMA_PORT=$pmaPort

        if [[ ! -f docker-compose.yml ]]; then
            $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/mysql/docker-compose-with-phpmyadmin.yml
        fi
    else
        if [[ ! -f docker-compose.yml ]]; then
            $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/mysql/docker-compose-without-phpmyadmin.yml
        fi
    fi

    if [[ ! -f manage.sh ]]; then
        $(which wget) -O manage.sh https://raw.githubusercontent.com/mindevis/scripts/main/composes/mysql/scripts/manage.sh
        $(which chmod) +x manage.sh
    fi

    if [[ $package = "percona" ]];then
        mysqlVersion="ps-$mysqlVersion"
    fi

    echo -e "${WARN}Initialization database configuration for MySQL.${NORMAL}"
    echo -e "${WARN}Backup database configuration file.${NORMAL}"
    $(which cp) docker-compose.yml{,.bak}
    echo -e "${WARN}Setup MySQL ${package}: ${mysqlVersion}.${NORMAL}"
    $(which sed) -i "s/PACKAGE/$package/g" docker-compose.yml
    $(which sed) -i "s/MYSQLVERSION/$mysqlVersion/g" docker-compose.yml
    echo -e "${WARN}Change default MySQL exposed port.${NORMAL}"
    $(which sed) -i "s/MYSQLPORT/$MYSQL_PORT/g" docker-compose.yml

    if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
        echo -e "${WARN}Change default phpmyadmin exposed port.${NORMAL}"
        $(which sed) -i "s/PMAPORT/$PMA_PORT/g" docker-compose.yml
        $(which sed) -i "s/PACKAGE/$package:$mysqlVersion phpmyadmin:latest/g" manage.sh
        $(which sed) -i "s/PMANW/$networkMainOctet.3/g" docker-compose.yml
    else
        $(which sed) -i "s/PACKAGE/$package:$mysqlVersion/g" manage.sh
    fi

    echo -e "${WARN}Generate MySQL root password.${NORMAL}"
    $(which sed) -i "s/MYSQLROOTPASSWORD/$MYSQL_ROOT_PASSWORD/g" docker-compose.yml
    echo -e "${WARN}Generate MySQL database.${NORMAL}"
    $(which sed) -i "s/MYSQLDATABASE/$MYSQL_DATABASE/g" docker-compose.yml
    echo -e "${WARN}Generate MySQL user.${NORMAL}"
    $(which sed) -i "s/MYSQLUSER/$MYSQL_USER/g" docker-compose.yml
    echo -e "${WARN}Generate MySQL user password.${NORMAL}"
    $(which sed) -i "s/MYSQLPASSWORD/$MYSQL_PASSWORD/g" docker-compose.yml

    $(which sed) -i "s/CIDR/$networkWithoutMask\/$networkMask/g" docker-compose.yml
    $(which sed) -i "s/GW/$networkMainOctet.1/g" docker-compose.yml
    $(which sed) -i "s/DBNW/$networkMainOctet.2/g" docker-compose.yml

    echo -e "${WARN}Start MySQL environment.${NORMAL}"
    $(which docker) compose up -d

    rm -f "$LOCK_FILE"
    rm -f "$0"
}

function checking() {
    OS=$($(which lsb_release) -is | grep -v LSB)
    if [[ ! $OS = "Debian" ]]; then
        echo -e "${BAD}Sorry, this script only works with Debian Linux.\nIf you need support for another Linux distribution, please submit a support request\nIssue: https://github.com/mindevis/scripts/issues/new${NORMAL}"
        exit 1
    fi

    OSSL=$($(which dpkg) -l | $(which grep) -w " openssl " | $(which cut) -d " " -f1)
    if [[ ! $OSSL = "ii" ]];then
        echo -e "${BAD}Openssl not found, openssl needed for generate passwords, install this package manually.${NORMAL}"
        exit 1
    fi

    WG=$($(which dpkg) -l | $(which grep) -w " wget " | $(which cut) -d " " -f1)
    if [[ ! $WG = "ii" ]];then
        echo -e "${BAD}Wget not found, wget needed for downloading scripts from github, install this package manually.${NORMAL}"
        exit 1
    fi

    DC=$($(which dpkg) -l | $(which grep) -w " docker-ce " | $(which cut) -d " " -f1)
    if [[ ! $DC = "ii" ]];then
        echo -e "${BAD}Docker Engine not found, docker engine needed for run applications in containers, install this package manually.${NORMAL}"
        exit 1
    fi

    DCC=$($(which dpkg) -l | $(which grep) -w " docker-compose-plugin " | $(which cut) -d " " -f1)
    if [[ ! $DCC = "ii" ]];then
        echo -e "${BAD}Docker Compose plugin not found, docker compose plugin needed for run compose files, install this package manually.${NORMAL}"
        exit 1
    fi

    $(which touch) $LOCK_FILE
    setup
}

# Entrypoint to script
case "$1" in
    --setup)
        count=1
        for arguments in "$@"; do
            if [[ "$arguments" = "--package" ]]; then
                package="$2"
            fi

            if [[ "$arguments" = "--version" ]]; then
                mysqlVersion="$2"
            fi

            if [[ "$arguments" = "--network" ]]; then
                networkCIDR="$2"
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

        networkCIDR="${networkCIDR:-"10.2.26.0/24"}"
        networkMask="$(echo "$networkCIDR" | cut -d / -f2)"
        networkWithoutMask="$(echo "$networkCIDR" | cut -d / -f1)"
        networkMainOctet="$(echo "$networkWithoutMask" | cut -d. -f-3)"

        if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
            if [[ -z $package ]] || [[ -z $mysqlVersion ]] || [[ -z $mysqlPort ]] || [[ -z $pmaPort ]]; then
                echo -e "${BAD}You have not specified all required arguments.${NORMAL}"
                exit 1
            fi
        else
            if [[ -z $package ]] || [[ -z $mysqlVersion ]] || [[ -z $mysqlPort ]]; then
                echo -e "${BAD}You have not specified all required arguments.${NORMAL}"
                exit 1
            fi
        fi

        checking
esac