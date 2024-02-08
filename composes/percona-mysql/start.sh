#!/usr/bin/env bash

echo -e "${WARN}Start Percona MySQL environment.${NORMAL}"
$(which docker) compose up -d