#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(<"${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

file_env "DB_PASSWORD"
echo $DB_PASSWORD

if [[ -n "${DRUPAL_VERSION}" ]]; then
    if [[ "${DRUPAL_VERSION}" == 7 ]] || [[ "${DRUPAL_VERSION}" == 8 ]]; then
        gotpl "/etc/gotpl/sites.php.tmpl" > "${CONF_DIR}/wodby.sites.php"
    fi

    gotpl "/etc/gotpl/drupal${DRUPAL_VERSION}.settings.php.tmpl" > "${CONF_DIR}/wodby.settings.php"

    if [[ "${DRUPAL_VERSION}" == 8 ]]; then
        sudo init_container "${FILES_DIR}/config/sync_${DRUPAL_FILES_SYNC_SALT}"
    fi
fi
