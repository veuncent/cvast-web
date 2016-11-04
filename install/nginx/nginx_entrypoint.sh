#!/bin/bash

# For Letsencrypt / Certbot verification
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}
LETSENCRYPT_BASE_PATH=/etc/letsencrypt
NGINX_DEFAULT_CONF=/etc/nginx/conf.d/default.conf
NGINX_ROOT=/var/www

start_nginx_daemon() {
	cp ${INSTALL_DIR}/default.conf ${NGINX_DEFAULT_CONF}
	
	# Set name of host and Django container
	echo "Initializing NginX to run on ${DOMAIN_NAME} and serve as reverse proxy for ${DJANGO_HOST}..."
	sed -i "s/<django_host>/${DJANGO_HOST}/g" ${NGINX_DEFAULT_CONF}
	sed -i "s/<domain_name>/${DOMAIN_NAME}/g" ${NGINX_DEFAULT_CONF}

	echo "Running Nginx on ${DOMAIN_NAME} in the foreground"
	exec nginx -g 'daemon off;'
}

download_certificates() {
	echo "Downloading new certificate from LetsEncrypt..."
	cp ${INSTALL_DIR}/nginx_http_only.conf ${NGINX_DEFAULT_CONF} # Http-only nginx conf
	sed -i "s/<domain_name>/${DOMAIN_NAME}/g" ${NGINX_DEFAULT_CONF}
	
	mkdir ${NGINX_ROOT}/${DOMAIN_NAME}
	
	echo "Temporarilly starting NginX in order to let Certbot verify something is running on port 80..."
	service nginx start
	
	echo "Starting Certbot to download certificate"
	certbot certonly \
		--agree-tos \
		--text \
		--non-interactive \
		--email ${LETSENCRYPT_EMAIL} \
		--webroot \
		-w /var/www/${DOMAIN_NAME} \
		-d ${DOMAIN_NAME} \
		${ADDITIONAL_CERTBOT_PARAMS}
	
	if [[ $? != 0 ]]; then
		echo "Failed to download certificate with Certbot, exiting..."
		exit 1
	else
		echo "Stopping Nginx in order to reload config and run it in the foreground..."
		service nginx stop
	fi
}

renew_certificates() {
	echo "Checking if certificates needs to be renewed..."
	certbot renew --dry-run
}

# Starting point
mkdir -p ${NGINX_ROOT}

if [[ ${DEV_MODE} == True ]]; then
	echo "DEV_MODE = True, so not downloading any certificate from LetsEncrypt"
else
	if [[ -d "$LETSENCRYPT_BASE_PATH/live/${DOMAIN_NAME}" ]]; then
		echo "Certificate already exists in $LETSENCRYPT_BASE_PATH/live/${DOMAIN_NAME}"
		renew_certificates
	else
		echo "No certificate exists for doman: ${DOMAIN_NAME}"
		download_certificates
	fi
fi

if [[ ${PUBLIC_MODE} == True ]]; then
	cp ${INSTALL_DIR}/robots_public.txt ${NGINX_ROOT}/robots.txt
else 
	cp ${INSTALL_DIR}/robots_private.txt ${NGINX_ROOT}/robots.txt
fi

start_nginx_daemon