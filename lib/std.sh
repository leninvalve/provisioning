#!/usr/bin/bash

HOSTS_DIR="/srv/clients"	# All clients's home here.
HOSTS_DIR_PERMS="701"
HOSTS_DIR_OWNER="root:root"

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

pre_flight() {
	local perms
	local owner

	[[ -d "$HOSTS_DIR" ]] || { LAST_ERROR="'$HOSTS_DIR' missing. Aborting."; return 1; }
	
	perms=$(stat -c %a "$HOSTS_DIR")
	[[ "$perms" == "$HOSTS_DIR_PERMS" ]] || { LAST_ERROR="'$HOSTS_DIR' wrong permissions: $perms. Expected: '$HOSTS_DIR_PERMS'"; return 1; }

	owner=$(stat -c %U:%G "$HOSTS_DIR")
	[[ "$owner" == "$HOSTS_DIR_OWNER" ]] || { LAST_ERROR="'$HOSTS_DIR' wrong owner: $owner. Expected: '$HOSTS_DIR_OWNER'"; return 1; }

	command -v setfacl &> /dev/null || { LAST_ERROR="Command 'setfacl' not installed. Aborting."; return 1; }
	command -v php-fpm${PHP_VERSION} &> /dev/null || { LAST_ERROR="PHP-FPM $PHP_VERSION not installed. Aborting."; return 1; }
	command -v mariadb &> /dev/null || { LAST_ERROR="MariaDB not installed. Aborting."; return 1; }
	
	# All tests passed. Go ahead!
	return 0
}
