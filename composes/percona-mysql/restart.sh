#!/usr/bin/env bash

echo -e "${WARN}Restart Percona MySQL environment.${NORMAL}"
$(which docker) compose restart