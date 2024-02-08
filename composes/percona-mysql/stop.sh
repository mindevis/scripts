#!/usr/bin/env bash

echo -e "${WARN}Stop Percona MySQL environment.${NORMAL}"
$(which docker) compose down