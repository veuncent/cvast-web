#!/bin/bash

set -- ${DOMAIN_NAMES}
PRIMARY_DOMAIN_NAME=$1
LETSENCRYPT_BASEDIR=/etc/letsencrypt
LETSENCRYPT_LOCALHOST_DIR=${LETSENCRYPT_BASEDIR}/live/localhost
NGINX_DEFAULT_CONF=/etc/nginx/conf.d/default.conf
NGINX_ROOT=/var/www

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
	mkdir -p ${NGINX_ROOT}
	if [[ ${PUBLIC_MODE} == True ]]; then
		cp ${INSTALL_DIR}/robots_public.txt ${NGINX_ROOT}/robots.txt
	else 
		cp ${INSTALL_DIR}/robots_private.txt ${NGINX_ROOT}/robots.txt
	fi
}

set_strict_https_nginx_conf() {
	cp ${INSTALL_DIR}/nginx_strict_https.conf ${NGINX_DEFAULT_CONF}
	echo "Initializing NginX to run on: ${DOMAIN_NAMES}"
	echo "... and serve as reverse proxy for Docker container: ${DJANGO_HOST}..."
	sed -i "s/<django_host>/${DJANGO_HOST}/g" ${NGINX_DEFAULT_CONF}
	sed -i "s/<domain_names>/${DOMAIN_NAMES}/g" ${NGINX_DEFAULT_CONF}
	sed -i "s/<primary_domain_name>/${PRIMARY_DOMAIN_NAME}/g" ${NGINX_DEFAULT_CONF}
}

copy_localhost_certificates() {
	mkdir -p ${LETSENCRYPT_LOCALHOST_DIR}
	cp ${INSTALL_DIR}/fullchain.pem ${LETSENCRYPT_LOCALHOST_DIR}
	cp ${INSTALL_DIR}/privkey.pem ${LETSENCRYPT_LOCALHOST_DIR}
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
check_variable "${DOMAIN_NAMES}" DOMAIN_NAMES
check_variable "${DJANGO_HOST}" DJANGO_HOST

set_strict_https_nginx_conf
copy_localhost_certificates

# This is in case you forget to close ports 80/443 on a test/demo environment: 
# Environment variable PUBLIC_MODE needs to be explicitly set to True if search enginges should pick this up
set_search_engine_settings

start_nginx_background
wait_for_certificate
stop_nginx_background

start_nginx_foreground