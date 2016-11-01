#!/bin/bash

DOMAIN_NAME=${DOMAIN_NAME}
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}

sed -i "s/<django_host>/${DJANGO_HOST}/g" /etc/nginx/conf.d/default.conf
sed -i "s/<domain_name>/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf

mkdir -p /var/www/${DOMAIN_NAME}

if [[ ${GET_NEW_CERTIFICATE} == True ]]; then
	certbot certonly \
		--agree-tos \
		--email ${LETSENCRYPT_EMAIL} \
		--webroot \
		-w /var/www/${DOMAIN_NAME} \
		-d ${DOMAIN_NAME} \
		${ADDITIONAL_CERTBOT_PARAMS}
fi

exec nginx -g 'daemon off;'