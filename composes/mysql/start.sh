#!/usr/bin/env bash
if  [ "$TERM" = "linux" ] || [ "$TERM" = "xterm" ] || [ "$TERM" = "xterm-color" ] || [ "$TERM" = "screen" ] && [ "$USE_COLORS" = "1" ]; then
    WARN=$'\e[33;01m'
    NORMAL=$'\e[0m'
else
    NORMAL=$'\e[0m'
    WARN=$'\e[0;33m'
fi

echo -e "${WARN}Start MySQL environment.${NORMAL}"
$(which docker) compose up -d