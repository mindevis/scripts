#!/usr/bin/env bash
if  [ "$TERM" = "linux" ] || [ "$TERM" = "xterm" ] || [ "$TERM" = "xterm-color" ] || [ "$TERM" = "screen" ] && [ "$USE_COLORS" = "1" ]; then
    WARN=$'\e[33;01m'
    NORMAL=$'\e[0m'
else
    NORMAL=$'\e[0m'
    WARN=$'\e[0;33m'
fi

function start() {
    echo -e "${WARN}Start GitLab environment.${NORMAL}"
    $(which docker) compose up -d
    exit 0
}

function stop() {
    echo -e "${WARN}Stop GitLab environment.${NORMAL}"
    $(which docker) compose stop
    exit 0
}

function restart() {
    echo -e "${WARN}Restart GitLab environment.${NORMAL}"
    $(which docker) compose restart
    exit 0
}

function destroy() {
    echo -e "${WARN}Destroy GitLab environment.${NORMAL}"
    $(which docker) compose -f docker-compose.yml down
    $(which docker) volume rm --force gitlab_configs gitlab_data gitlab_logs gitlab_runner_data s3_object_data
    $(which docker) volume prune --force
    $(which docker) rmi PACKAGE
    exit 0
}

# Entrypoint to script
case "$1" in
    --start) start;;
    --stop) stop;;
    --restart) restart;;
    --destroy) destroy;;
esac