#!/bin/bash

set -- ${DOMAIN_NAMES}
PRIMARY_DOMAIN_NAME=$1
LETSENCRYPT_BASEDIR="${LETSENCRYPT_BASEDIR:-/etc/letsencrypt}"
LETSENCRYPT_LIVEDIR=${LETSENCRYPT_BASEDIR}/live
LETSENCRYPT_LOCALHOST_DIR=${LETSENCRYPT_LIVEDIR}/localhost
LETSENCRYPT_DOMAIN_DIR=${LETSENCRYPT_LIVEDIR}/${PRIMARY_DOMAIN_NAME}
NGINX_DEFAULT_CONF="${NGINX_DEFAULT_CONF:-/etc/nginx/conf.d/default.conf}"
WEB_ROOT="${WEB_ROOT:-/var/www}"
FULLCHAIN_FILENAME=fullchain.pem
PRIVATE_KEY_FILENAME=privkey.pem

CERTIFICATE_WAIT_TIMEOUT="${CERTIFICATE_WAIT_TIMEOUT:-15}"

wait_for_certificate() {
	sleep $CERTIFICATE_WAIT_TIMEOUT
}

start_nginx_background() {
    echo "Temporarilly starting NginX in order to let the certificate service verify something is running on port 80..."
	service nginx start
}

stop_nginx_background() {
    echo "Stopping Nginx in order to reload config and run it in the foreground..."
	service nginx stop
}

start_nginx_foreground() {
	echo "Running Nginx on ${DOMAIN_NAME} in the foreground"
	exec nginx -g 'daemon off;'
}

set_search_engine_settings() {
	if [[ ${PUBLIC_MODE} == True ]]; then
		allow_text="" 
		sed -i "s/<allow_or_disallow>/${allow_text}/g" ${NGINX_DEFAULT_CONF}
	else 
		disallow_text=" /" 
		sed -i "s#<allow_or_disallow>#${disallow_text}#g" ${NGINX_DEFAULT_CONF}
	fi
}

set_strict_https_nginx_conf() {
	cp ${INSTALL_DIR}/nginx_strict_https.conf ${NGINX_DEFAULT_CONF}
	echo "Initializing NginX to run on: ${DOMAIN_NAMES}"
	echo "... and serve as reverse proxy for Docker container: ${PROXY_CONTAINER}..."
	sed -i "s/<proxy_container>/${PROXY_CONTAINER}/g" ${NGINX_DEFAULT_CONF}
	sed -i "s/<domain_names>/${DOMAIN_NAMES}/g" ${NGINX_DEFAULT_CONF}
	sed -i "s/<primary_domain_name>/${PRIMARY_DOMAIN_NAME}/g" ${NGINX_DEFAULT_CONF}
}

set_nginx_certificate_paths() {
	echo "Setting NginX certificate conf to use certificates in ${LETSENCRYPT_DOMAIN_DIR}..."
	sed -i "s#${LETSENCRYPT_LOCALHOST_DIR}#${LETSENCRYPT_DOMAIN_DIR}#g" ${NGINX_DEFAULT_CONF}
}

copy_localhost_certificates() {
	mkdir -p ${LETSENCRYPT_LOCALHOST_DIR}
	if [[ ! -f ${LETSENCRYPT_LOCALHOST_DIR}/${FULLCHAIN_FILENAME} ]]; then
		cp ${INSTALL_DIR}/${FULLCHAIN_FILENAME} ${LETSENCRYPT_LOCALHOST_DIR}
	fi
	if [[ ! -f ${LETSENCRYPT_LOCALHOST_DIR}/${PRIVATE_KEY_FILENAME} ]]; then
		cp ${INSTALL_DIR}/${PRIVATE_KEY_FILENAME} ${LETSENCRYPT_LOCALHOST_DIR}
	fi	
}

check_variable() {
	local VARIABLE_VALUE=$1
	local VARIABLE_NAME=$2
	if [[ -z ${VARIABLE_VALUE} ]] || [[ "${VARIABLE_VALUE}" == "" ]]; then
		echo "ERROR! Environment variable ${VARIABLE_NAME} not specified. Exiting..."
		exit 1
	fi 
}

#### Starting point
# For LetsEncrypt acme challange
mkdir -p ${WEB_ROOT}

check_variable "${DOMAIN_NAMES}" DOMAIN_NAMES
check_variable "${PROXY_CONTAINER}" PROXY_CONTAINER

set_strict_https_nginx_conf
copy_localhost_certificates

# This is in case you forget to close ports 80/443 on a test/demo environment: 
# Environment variable PUBLIC_MODE needs to be explicitly set to True if search enginges should pick this up
set_search_engine_settings

start_nginx_background
wait_for_certificate
stop_nginx_background
set_nginx_certificate_paths

start_nginx_foreground