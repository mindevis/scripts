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
    # ATL_PORT=$atlPort
    # MYSQL_ROOT_PASSWORD=$($OPENSSL rand -hex 16)
    # PG_DATABASE=$(echo -e "db_$($OPENSSL rand -hex 4)")
    # PG_USER=$(echo -e "usr_$($OPENSSL rand -hex 4)")
    # PG_PASSWORD=$($OPENSSL rand -hex 16)
    s3_user=$(echo -e "usr_$($OPENSSL rand -hex 4)")
    s3_passwd=$($OPENSSL rand -hex 16)

    # if [[ ! -d agent ]]; then 
    #      $(which mkdir) agent
    # fi

    # if [[ ! -f agent/atlassian-agent.bak ]]; then
    #    $(which wget) -O agent/atlassian-agent.bak https://github.com/mindevis/scripts/raw/main/composes/atlassian/agent/atlassian-agent.bak
    # fi

    # if [[ $(echo "$pgEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
    #     if [[ ! -f docker-compose.yml ]]; then
    #         $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/atlassian/jira-with-postgresql.yml
    #     fi
    # else
    if [[ ! -f docker-compose.yml ]]; then
        $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitlab/gitlab-with-s3-runner.yml
    fi
    # fi

    if [[ ! -f manage.sh ]]; then
        $(which wget) -O manage.sh https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitlab/scripts/manage.sh
        $(which chmod) +x manage.sh
    fi

    # if [[ $package = "percona" ]];then
    #     mysqlVersion="ps-$mysqlVersion"
    # fi

    echo -e "${WARN}Initialization GitLab configuration${NORMAL}"
    echo -e "${WARN}Backup GitLab configuration file.${NORMAL}"
    $(which cp) docker-compose.yml{,.bak}

    echo -e "${WARN}Setup ${package}.${NORMAL}"
    $(which sed) -i "s/PACKAGE/$package/g" docker-compose.yml
    if [[ $package == "gitlab" ]]; then
        $(which sed) -i "s/IMG/$package\/$package-ce:latest/g" docker-compose.yml
    fi
    $(which sed) -i "s/DOMAIN/$domain/g" docker-compose.yml
    $(which sed) -i "s/GSSHPORT/$git_ssh_port/g" docker-compose.yml
    $(which sed) -i "s/GHTTPPORT/$git_http_port:80/g" docker-compose.yml
    if [[ ! -z $git_https_port ]];then
        $(which sed) -i "s/- \"$git_http_port:80\"/a - $git_https_port:443/g" docker-compose.yml
    fi

    if [[ ! -z $s3_enable ]] && [[ $(echo "$s3_enable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
        $(which sed) -i "s/S3USER/$s3_user/g" docker-compose.yml
        $(which sed) -i "s/S3PASSWD/$s3_passwd/g" docker-compose.yml
        $(which sed) -i "s/S3WEBPORT/$s3_web_port/g" docker-compose.yml
        $(which sed) -i "s/S3CONSOLEPORT/$s3_console_port/g" docker-compose.yml
    fi

    # echo -e "${WARN}Change default MySQL exposed port.${NORMAL}"
    # $(which sed) -i "s/ATLPORT/$ATL_PORT/g" docker-compose.yml

    # if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
    #     echo -e "${WARN}Change default pgadmin exposed port.${NORMAL}"
    #     $(which sed) -i "s/PMAPORT/$PMA_PORT/g" docker-compose.yml
    #     $(which sed) -i "s/PACKAGE/$package:latest pgadmin:latest/g" manage.sh
    #     $(which sed) -i "s/PMANW/$networkMainOctet.3/g" docker-compose.yml
    # else
    if [[ $package == "gitlab" ]]; then
        $(which sed) -i "s/PACKAGE/$package-ce:latest/g" manage.sh
    else
        $(which sed) -i "s/PACKAGE/$package:latest/g" manage.sh
    fi
    # fi

    # echo -e "${WARN}Generate MySQL root password.${NORMAL}"
    # $(which sed) -i "s/MYSQLROOTPASSWORD/$MYSQL_ROOT_PASSWORD/g" docker-compose.yml
    # echo -e "${WARN}Generate MySQL database.${NORMAL}"
    # $(which sed) -i "s/PGDATABASE/$PG_DATABASE/g" docker-compose.yml
    # echo -e "${WARN}Generate MySQL user.${NORMAL}"
    # $(which sed) -i "s/PGUSER/$PG_USER/g" docker-compose.yml
    # echo -e "${WARN}Generate MySQL user password.${NORMAL}"
    # $(which sed) -i "s/PGPASSWORD/$PG_PASSWORD/g" docker-compose.yml

    $(which sed) -i "s/CIDR/$networkWithoutMask\/$networkMask/g" docker-compose.yml
    $(which sed) -i "s/GW/$networkMainOctet.1/g" docker-compose.yml
    $(which sed) -i "s/CONT1/$networkMainOctet.2/g" docker-compose.yml
    $(which sed) -i "s/CONT2/$networkMainOctet.3/g" docker-compose.yml
    $(which sed) -i "s/CONT3/$networkMainOctet.4/g" docker-compose.yml

    echo -e "${WARN}Start $package environment.${NORMAL}"
    $(which docker) compose up -d

    echo -e "${WARN}S3 USER: $s3_user | S3 PASSWORD: $s3_passwd.${NORMAL}"

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
            if [[ "$arguments" = "--package" ]]; then # gitlab, jira, mysql, mediawiki, docurus
                package="$2"
            fi

            if [[ "$arguments" = "--domain" ]]; then
                domain="$2"
            fi

            if [[ "$arguments" = "--git-ssh-port" ]]; then
                git_ssh_port="$2"
            fi

            if [[ "$arguments" = "--git-http-port" ]]; then
                git_http_port="$2"
            fi

            if [[ "$arguments" = "--git-https-port" ]]; then
                git_https_port="$2"
            fi

            if [[ "$arguments" = "--with-s3" ]]; then
                s3_enable="$2"
            fi 

            if [[ "$arguments" = "--s3-web-port" ]]; then
                s3_web_port="$2"
            fi

            if [[ "$arguments" = "--s3-console-port" ]]; then
                s3_console_port="$2"
            fi  

            # if [[ "$arguments" = "--version" ]]; then
            #     mysqlVersion="$2"
            # fi

            if [[ "$arguments" = "--network" ]]; then
                networkCIDR="$2"
            fi

            # if [[ "$arguments" = "--jira-port" ]]; then
            #     atlPort="$2"
            # fi

            # if [[ "$arguments" = "--pg-enable" ]]; then
            #     pgEnable="$2"
            # fi

            # if [[ "$arguments" = "--pma-port" ]]; then
            #     pmaPort="$2"
            # fi

            count=$(( "$count" + 1 ))
            shift
        done

        networkCIDR="${networkCIDR:-"10.2.26.0/24"}"
        networkMask="$(echo "$networkCIDR" | cut -d / -f2)"
        networkWithoutMask="$(echo "$networkCIDR" | cut -d / -f1)"
        networkMainOctet="$(echo "$networkWithoutMask" | cut -d. -f-3)"

        # if [[ $(echo "$pmaEnable" | $(which tr) '[:lower:]' '[:upper:]') = "TRUE" ]]; then
        #     if [[ -z $package ]] || [[ -z $mysqlVersion ]] || [[ -z $atlPort ]] || [[ -z $pmaPort ]]; then
        #         echo -e "${BAD}You have not specified all required arguments.${NORMAL}"
        #         exit 1
        #     fi
        # else
        if [[ -z $package ]]; then
            echo -e "${BAD}You have not specified all required arguments.${NORMAL}"
            exit 1
        fi
        # fi

        checking
esac