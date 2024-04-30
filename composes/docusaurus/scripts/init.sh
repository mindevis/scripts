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

LOCK_FILE="/tmp/setup-docusaurus.lock"

function setup() {

    if [[ ! -f docker-compose.yml ]]; then
        $(which wget) -O docker-compose.yml https://raw.githubusercontent.com/mindevis/scripts/main/composes/docusaurus/docker-compose.yml
    fi

    if [[ ! -f Dockerfile ]]; then
        $(which wget) -O Dockerfile https://raw.githubusercontent.com/mindevis/scripts/main/composes/docusaurus/Dockerfile
    fi

    if [[ ! -f manage.sh ]]; then
        $(which wget) -O manage.sh https://raw.githubusercontent.com/mindevis/scripts/main/composes/docusaurus/scripts/manage.sh
        $(which chmod) +x manage.sh
    fi

    echo -e "${WARN}Initialization docusaurus configuration.${NORMAL}"
    echo -e "${WARN}Backup docker-compose.yml configuration file.${NORMAL}"
    $(which cp) docker-compose.yml{,.bak}
    echo -e "${WARN}Setup docusaurus.${NORMAL}"
    $(which sed) -i "s/DSPORT/$dsPort/g" docker-compose.yml

    echo -e "${WARN}Setup docusaurus network configuration.${NORMAL}"
    $(which sed) -i "s/CIDR/$networkWithoutMask\/$networkMask/g" docker-compose.yml
    $(which sed) -i "s/GW/$networkMainOctet.1/g" docker-compose.yml
    $(which sed) -i "s/DSNW/$networkMainOctet.2/g" docker-compose.yml

    echo -e "${WARN}Start docusaurus environment.${NORMAL}"
    $(which docker) compose up -d

    ln -sf /var/lib/docker/volumes/docusaurus-data/_data/docusaurus.config.js $(pwd)/docusaurus.config.js
    ln -sf /var/lib/docker/volumes/docusaurus-data/_data/blog $(pwd)/blog
    ln -sf /var/lib/docker/volumes/docusaurus-data/_data/docs $(pwd)/docs
    ln -sf /var/lib/docker/volumes/docusaurus-data/_data/sidebars.js $(pwd)/sidebars.js
    

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
            if [[ "$arguments" = "--network" ]]; then
                networkCIDR="$2"
            fi

            if [[ "$arguments" = "--port" ]]; then
                dsPort="$2"
            fi
            count=$(( "$count" + 1 ))
            shift
        done

        networkCIDR="${networkCIDR:-"10.2.26.0/24"}"
        networkMask="$(echo "$networkCIDR" | cut -d / -f2)"
        networkWithoutMask="$(echo "$networkCIDR" | cut -d / -f1)"
        networkMainOctet="$(echo "$networkWithoutMask" | cut -d. -f-3)"

        checking
esac