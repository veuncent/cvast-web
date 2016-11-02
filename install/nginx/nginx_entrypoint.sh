#!/bin/bash

# For Letsencrypt / Certbot verification
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}

# Set name of Django container
echo "Initializing NginX to run on ${DOMAIN_NAME} and serve as reverse proxy for ${DJANGO_HOST}..."
sed -i "s/<django_host>/${DJANGO_HOST}/g" /etc/nginx/conf.d/default.conf
sed -i "s/<domain_name>/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf


if [[ ${GET_NEW_CERTIFICATE} == True ]]; then
	echo "GET_NEW_CERTIFICATE = True, so downloading new certificate from LetsEncrypt"
		
	# Temporary dummy certs so Nginx will startup without complaining
	mkdir -p /etc/letsencrypt/live/${DOMAIN_NAME}
	cp ${INSTALL_DIR}/fullchain.pem /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;
	cp ${INSTALL_DIR}/privkey.pem /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem;
	
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
	
	echo "Stopping Nginx in order to reload config and run it in the foreground..."
	service nginx stop
	
	echo "Running Nginx on ${DOMAIN_NAME} in the foreground"
	exec nginx -g 'daemon off;'
	
else
	echo "Running Nginx on ${DOMAIN_NAME} without downloading new certificate"
	exec nginx -g 'daemon off;' 
fi

