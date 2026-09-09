#!/usr/bin/bash

CLIENTS_DIR="/srv/clients"	# All clients's home here.
CLIENTS_DIR_PERMS="701"
CLIENTS_DIR_OWNER="root:root"

# For a single client:
USER_DIR_PERMS="701"				# User's home dir. www, logs and related dirs live here.
USER_DIR_OWNER="root:root" 	# User's home dir is owned by root. Required for ssh jail.
USER_WWW_PERMS="750"				# www-data belongs to group (via ACL). Group can read and exec (dirs).
USER_TMP_PERMS="700"				# For PHP session data.
USER_LOGS_PERMS="700"				# nginx and php-fpm logs.
USER_PRIVATE_PERMS="700"		# Secrets user may have live here.

PHP_VERSION="8.4"

LAST_ERROR=""

log_err() { echo "ERROR: $1"; return 0; }
log_ok() { echo "OK: $1"; return 0; }

fail() { LAST_ERROR="$1"; return 1; }

pre_flight() {
	if [ ! -d "$CLIENTS_DIR" ]; then
		fail "'$CLIENTS_DIR' missing. Aborting."
	fi
	
	local perms
	perms=$(stat -c %a "$CLIENTS_DIR")
 	if [ "$perms" != "$CLIENTS_DIR_PERMS" ]; then
		LAST_ERROR="'$CLIENTS_DIR' wrong permissions. Given: '$perms'. Expected: '$CLIENTS_DIR_PERMS'"
		return 1
	fi
	local owner
	owner=$(stat -c %U:%G "$CLIENTS_DIR")
	if [ "$owner" != "$CLIENTS_DIR_OWNER" ]; then
		LAST_ERROR="'$CLIENTS_DIR' wrong owner. Given: '$owner'. Expected: '$CLIENTS_DIR_OWNER'"
		return 1
	fi

	if ! command -v setfacl &> /dev/null; then
		LAST_ERROR="Command 'setfacl' not installed. Aborting."
		return 1
	fi

	if ! command -v php-fpm${PHP_VERSION} &> /dev/null; then
		LAST_ERROR="PHP-FPM $PHP_VERSION not installed. Aborting."
		return 1
	fi

	if ! command -v mariadb &> /dev/null; then
		LAST_ERROR="MariaDB not installed. Aborting."
		return 1
	fi
	
	# All tests passed. Go ahead!
	return 0
}
