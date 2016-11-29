#!/bin/bash

# For Letsencrypt / Certbot verification
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}
LETSENCRYPT_BASE_PATH=/etc/letsencrypt
NGINX_DEFAULT_CONF=/etc/nginx/conf.d/default.conf
NGINX_ROOT=/var/www

check_if_aws() {
	# If we can get an AWS private ip, it means we are on an EC2 instance
	AWS_PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
	if [[ ! -z $AWS_PRIVATE_IP ]]; then
		echo "Running on an AWS EC2 instance..."
		return 0
	else
		echo "Not running on an AWS EC2 instance..."
		return 1
	fi
}

set_aws_settings() {
	check_if_aws
	if [[ $? == 0 ]]; then
		USE_LETSENCRYPT=False
		set_http_only_nginx_conf
	fi
}

set_strict_https_nginx_conf() {
	cp ${INSTALL_DIR}/nginx_strict_https.conf ${NGINX_DEFAULT_CONF}
	echo "Initializing NginX to run on ${DOMAIN_NAME} and serve as reverse proxy for ${DJANGO_HOST}..."
	sed -i "s/<django_host>/${DJANGO_HOST}/g" ${NGINX_DEFAULT_CONF}
	sed -i "s/<domain_name>/${DOMAIN_NAME}/g" ${NGINX_DEFAULT_CONF}
}

set_http_only_nginx_conf() {
	cp ${INSTALL_DIR}/nginx_http_only.conf ${NGINX_DEFAULT_CONF}
	sed -i "s/<domain_name>/${DOMAIN_NAME}/g" ${NGINX_DEFAULT_CONF}
}

start_nginx_daemon() {
	echo "Running Nginx on ${DOMAIN_NAME} in the foreground"
	exec nginx -g 'daemon off;'
}

download_certificates() {
	echo "Preparing to download new certificate from LetsEncrypt..."
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
	certbot renew
}

set_search_engine_settings() {
	if [[ ${PUBLIC_MODE} == True ]]; then
		cp ${INSTALL_DIR}/robots_public.txt ${NGINX_ROOT}/robots.txt
	else 
		cp ${INSTALL_DIR}/robots_private.txt ${NGINX_ROOT}/robots.txt
	fi
}


#### Starting point
mkdir -p ${NGINX_ROOT}

# Use strict https by default (currently for local and non-aws servers)
set_strict_https_nginx_conf

# AWS has its own certificate manager, which we manage manually
set_aws_settings

if [[ ! ${USE_LETSENCRYPT} == True ]]; then
	echo "USE_LETSENCRYPT = False, so not downloading any certificate from LetsEncrypt"
	# echo "Removing letsencrypt certificate paths from  nginx.conf"
	# sed -i "\#ssl_certificate /etc/letsencrypt#d" ${NGINX_DEFAULT_CONF}
	# sed -i "\#ssl_certificate_key /etc/letsencrypt#d" ${NGINX_DEFAULT_CONF}
else
	if [[ -d "$LETSENCRYPT_BASE_PATH/live/${DOMAIN_NAME}" ]]; then
		echo "Certificate already exists in $LETSENCRYPT_BASE_PATH/live/${DOMAIN_NAME}"
		renew_certificates
	else
		echo "No certificate exists for doman: ${DOMAIN_NAME}"
		set_http_only_nginx_conf
		download_certificates
		set_strict_https_nginx_conf
	fi
fi

# This is in case you forget to close ports 80/443 on a test/demo environment: 
# Environment variable PUBLIC_MODE needs to be explicitly set to True if search enginges should pick this up
set_search_engine_settings

start_nginx_daemon