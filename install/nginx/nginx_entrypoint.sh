#!/bin/bash

# For Letsencrypt / Certbot verification
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}
NGINX_DEFAULT_CONF=/etc/nginx/conf.d/default.conf

start_nginx_daemon() {
	cp ${INSTALL_DIR}/default.conf ${NGINX_DEFAULT_CONF}
	
	# Set name of host and Django container
	echo "Initializing NginX to run on ${DOMAIN_NAME} and serve as reverse proxy for ${DJANGO_HOST}..."
	sed -i "s/<django_host>/${DJANGO_HOST}/g" ${NGINX_DEFAULT_CONF}
	sed -i "s/<domain_name>/${DOMAIN_NAME}/g" ${NGINX_DEFAULT_CONF}

	exec nginx -g 'daemon off;'
}


if [[ ${GET_NEW_CERTIFICATE} == True ]]; then
	echo "GET_NEW_CERTIFICATE = True, so downloading new certificate from LetsEncrypt"

	# Http-only nginx conf
	cp ${INSTALL_DIR}/nginx_http_only.conf ${NGINX_DEFAULT_CONF}
	sed -i "s/<domain_name>/${DOMAIN_NAME}/g" ${NGINX_DEFAULT_CONF}
	
	mkdir -p /var/www/${DOMAIN_NAME}
	
	echo "Temporarilly starting NginX in order to let Certbot verify something is running on port 80..."
	service nginx start
	
	echo "Starting Certbot to download certificate"
	certbot certonly \
		--agree-tos \
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
		
		echo "Running Nginx on ${DOMAIN_NAME} in the foreground"
		start_nginx_daemon
	fi
else
	echo "Running Nginx on ${DOMAIN_NAME} without downloading new certificate"
	start_nginx_daemon 
fi

