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

LOCK_FILE="/tmp/setup.lock"

function setup() {
    OPENSSL=$(which openssl)
    if [[ ! -z $database ]];then
        MYSQL_PORT=$mysqlPort
        MYSQL_ROOT_PASSWORD=$($OPENSSL rand -hex 16)
        MYSQL_DATABASE=$(echo -e "db_$($OPENSSL rand -hex 4)")
        MYSQL_USER=$(echo -e "usr_$($OPENSSL rand -hex 4)")
        MYSQL_PASSWORD=$($OPENSSL rand -hex 16)
    fi

    if [[ ! -f docker-compose.yml ]]; then
        if [[ -z $database ]];then
            if [[ -z $git_https_port ]];then
                $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitea/gitea_with_http.yml
            else
                $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitea/gitea_with_https.yml
            fi
        else
            if [[ -z $git_https_port ]];then
                $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitea/gitea_with_http_with_database.yml
            else
                $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitea/gitea_with_https_with_database.yml
            fi
        fi
    fi

    if [[ ! -f manage.sh ]]; then
        $(which wget) -O manage.sh https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitea/scripts/manage.sh
        $(which chmod) +x manage.sh
    fi

    if [[ $database = "percona" ]];then
        mysqlVersion="ps-$mysqlVersion"
    fi

    echo -e "${WARN}Initialization Gitea configuration${NORMAL}"
    echo -e "${WARN}Backup Gitea configuration file.${NORMAL}"
    $(which cp) docker-compose.yml{,.bak}

    echo -e "${WARN}Setup Gitea.${NORMAL}"
    $(which sed) -i "s/DOMAIN/$domain/g" docker-compose.yml
    $(which sed) -i "s/GSSHPORT/$git_ssh_port/g" docker-compose.yml
    $(which sed) -i "s/GHTTPPORT/$git_http_port:3000/g" docker-compose.yml
    if [[ ! -z $git_https_port ]];then
        $(which sed) -i "s/GHTTPSPORT/$git_https_port:3080/g" docker-compose.yml
    fi

    if [[ ! -z $database ]];then
        echo -e "${WARN}Setup MySQL: ${mysqlVersion}.${NORMAL}"
        $(which sed) -i "s/PACKAGE/$database/g" docker-compose.yml
        $(which sed) -i "s/MYSQLVERSION/$mysqlVersion/g" docker-compose.yml
        echo -e "${WARN}Change default MySQL exposed port.${NORMAL}"
        $(which sed) -i "s/MYSQLPORT/$MYSQL_PORT/g" docker-compose.yml
        $(which sed) -i "s/PACKAGE/$database:$mysqlVersion/g" manage.sh

        echo -e "${WARN}Generate MySQL root password.${NORMAL}"
        $(which sed) -i "s/MYSQLROOTPASSWORD/$MYSQL_ROOT_PASSWORD/g" docker-compose.yml
        echo -e "${WARN}Generate MySQL database.${NORMAL}"
        $(which sed) -i "s/MYSQLDATABASE/$MYSQL_DATABASE/g" docker-compose.yml
        echo -e "${WARN}Generate MySQL user.${NORMAL}"
        $(which sed) -i "s/MYSQLUSER/$MYSQL_USER/g" docker-compose.yml
        echo -e "${WARN}Generate MySQL user password.${NORMAL}"
        $(which sed) -i "s/MYSQLPASSWORD/$MYSQL_PASSWORD/g" docker-compose.yml
        $(which sed) -i "s/CONT2/$networkMainOctet.3/g" docker-compose.yml
    else
        $(which sed) -i "s/PACKAGE//g" manage.sh
        $(which sed) -i "s/db-data//g" manage.sh
    fi

    $(which sed) -i "s/CIDR/$networkWithoutMask\/$networkMask/g" docker-compose.yml
    $(which sed) -i "s/GW/$networkMainOctet.1/g" docker-compose.yml
    $(which sed) -i "s/CONT1/$networkMainOctet.2/g" docker-compose.yml

    echo -e "${WARN}Start Gitea environment.${NORMAL}"
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
            if [[ "$arguments" = "--db" ]]; then # mariadb, percona, postgresql
                database="$2"
            fi

            if [[ "$arguments" = "--db-version" ]]; then
                mysqlVersion="$2"
            fi

            if [[ "$arguments" = "--db-port" ]]; then
                mysqlPort="$2"
            fi

            if [[ "$arguments" = "--domain" ]]; then
                domain="$2"
            fi

            if [[ "$arguments" = "--ssh-port" ]]; then
                git_ssh_port="$2"
            fi

            if [[ "$arguments" = "--http-port" ]]; then
                git_http_port="$2"
            fi

            if [[ "$arguments" = "--ssl" ]]; then
                git_https="$2"
            fi

            if [[ "$arguments" = "--ssl-port" ]]; then
                git_https_port="$2"
            fi

            if [[ "$arguments" = "--network" ]]; then
                networkCIDR="$2"
            fi

            count=$(( "$count" + 1 ))
            shift
        done

        if [[ ! -z $database ]];then
            mysqlVersion=${mysqlVersion:-8.0}
            mysqlPort=${mysqlPort:-3306}
        fi

        domain=${domain:-gitea.local}
        git_ssh_port=${git_ssh_port:-22}
        git_http_port=${git_http_port:-80}
        
        if [[ $(echo "$git_https" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]];then
            git_https_port=${git_https_port:-443}
        fi

        networkCIDR="${networkCIDR:-"10.2.26.0/24"}"
        networkMask="$(echo "$networkCIDR" | cut -d / -f2)"
        networkWithoutMask="$(echo "$networkCIDR" | cut -d / -f1)"
        networkMainOctet="$(echo "$networkWithoutMask" | cut -d. -f-3)"
        
        # if [[ -z $package ]]; then
        #     echo -e "${BAD}You have not specified all required arguments.${NORMAL}"
        #     exit 1
        # fi

        # if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
        #     if [[ -z $package ]] || [[ -z $mysqlVersion ]] || [[ -z $atlPort ]] || [[ -z $pmaPort ]]; then
        #         echo -e "${BAD}You have not specified all required arguments.${NORMAL}"
        #         exit 1
        #     fi
        # else
        # fi

        checking
esac