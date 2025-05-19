#!/usr/bin/env bash
set -eo pipefail

# Инициализация переменных по умолчанию
export USE_COLORS="${USE_COLORS:-1}"
LOCK_FILE="/tmp/setup-loki-app.lock"
BASE_URL="https://raw.githubusercontent.com/mindevis/scripts/main/composes/grafana/loki"
PERCONA_NETWORK_DEFAULT="10.2.26.0/24"
COMPOSE_CMD="docker compose"  # Default to modern compose plugin

# Обработка прерываний
trap 'cleanup' INT TERM EXIT

cleanup() {
    rm -f "$LOCK_FILE"
    exit 1
}

# Инициализация цветов
init_colors() {
    case "$TERM" in
        linux|xterm*|screen|tmux)
            [[ "$USE_COLORS" == "1" ]] && set_ansi_colors || set_basic_colors
            ;;
        *)
            set_basic_colors
            ;;
    esac
}

set_ansi_colors() {
    GOOD=$'\e[32;01m'
    WARN=$'\e[33;01m'
    BAD=$'\e[31;01m'
    NORMAL=$'\e[0m'
    HILITE=$'\e[37;01m'
    BRACKET=$'\e[34;01m'
}

set_basic_colors() {
    GOOD=$'\e[0;32m'
    WARN=$'\e[0;33m'
    BAD=$'\e[0;31m'
    NORMAL=$'\e[0m'
    HILITE=''
    BRACKET=$'\e[0m'
}

# Проверка зависимостей
check_dependencies() {
    local deps=("openssl" "wget" "docker")
    local missing=()

    # Проверка основных зависимостей
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    # Проверка Docker Compose
    if ! command -v "docker-compose" >/dev/null 2>&1; then
        if ! docker compose version >/dev/null 2>&1; then
            missing+=("docker-compose")
        else
            COMPOSE_CMD="docker compose"
        fi
    else
        COMPOSE_CMD="docker-compose"
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${BAD}Missing dependencies: ${missing[*]}${NORMAL}" >&2
        echo -e "Please verify:" >&2
        echo -e "1. Docker installation and permissions" >&2
        echo -e "2. Docker Compose (standalone or plugin)" >&2
        echo -e "3. Required packages: ${deps[*]}" >&2
        exit 1
    fi
}

escape_sed() {
    printf '%s\n' "$1" | sed -e 's/[\/&]/\\&/g'
}

# Основная логика настройки
setup() {
    local networkCIDR="${networkCIDR:-$PERCONA_NETWORK_DEFAULT}"
    local networkMask="${networkCIDR##*/}"
    local networkWithoutMask="${networkCIDR%/*}"
    local networkMainOctet=$(cut -d. -f-3 <<< "$networkWithoutMask")

    wget -q --show-progress -O docker-compose.yml \
        "${BASE_URL}/docker-compose.yml" || {
        echo -e "${BAD}Failed to download compose file!${NORMAL}" >&2
        exit 1
    }

    # Замена значений в шаблоне
    local sed_script=(
        -e "s|CIDR|${networkWithoutMask}/${networkMask}|g"
        -e "s|GW|${networkMainOctet}.1|g"
        -e "s|DBNW|${networkMainOctet}.2|g"
    )

    sed -i.bak "${sed_script[@]}" docker-compose.yml || {
        echo -e "${BAD}Template processing failed!${NORMAL}" >&2
        exit 1
    }

    # Загрузка скрипта управления
    if [[ ! -f manage.sh ]]; then
        wget -q --show-progress -O manage.sh "${BASE_URL}/scripts/manage.sh" || {
            echo -e "${BAD}Failed to download manage script!${NORMAL}" >&2
            exit 1
        }
        chmod +x manage.sh
    fi

    # Запуск контейнеров
    echo -e "${WARN}Starting Docker containers...${NORMAL}"
    ${COMPOSE_CMD} up -d || {
        echo -e "${BAD}Failed to start containers!${NORMAL}" >&2
        exit 1
    }

    # Финализация
    rm -f "$LOCK_FILE"
    trap - INT TERM EXIT
}

# Парсинг аргументов
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --setup)
                shift
                while [[ $# -gt 0 ]]; do
                    case "$1" in
                        --network) networkCIDR="${2:-}"; shift 2 ;;
                        *) echo -e "${BAD}Unknown parameter: $1${NORMAL}" >&2; exit 1 ;;
                    esac
                done
                ;;
            *) echo -e "${BAD}Unknown command: $1${NORMAL}" >&2; exit 1 ;;
        esac
    done
}

# Главная функция
main() {
    init_colors
    check_dependencies
    parse_arguments "$@"
    setup
}

# Точка входа
main "$@"