Setting up a Docker Private Registry
====================================
			
source: https://coderwall.com/p/dtwc1q/insecure-and-self-signed-private-docker-registry-with-boot2docker



Installation (server side)
--------------------------

First create a key and certificate:
	root@registry:~# mkdir /certs
	root@registry:~# openssl req \
	  -newkey rsa:4096 -nodes -sha256 \
	  -keyout certs/domain.key \
	  -x509 -days 356 \
	  -out certs/domain.crt
  
**!** For 'Common Name (e.g. server FQDN or YOUR name)', use our domain name (e.g. cvast-build.eastus.cloudapp.azure.com)


Set up basic auth on our registry host:

	root@registry:~# mkdir /auth
	root@registry:~# docker run --entrypoint htpasswd registry:2 -Bnb <username> <password> > auth/htpasswd

Include this in your docker-compose.yml: 
  environment:
    REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.crt
    REGISTRY_HTTP_TLS_KEY: /certs/domain.key
    REGISTRY_AUTH: htpasswd
    REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm

Run the registry container (from the docker-registry folder):
	docker-compose up

	
	
Installation (client side, Unix)
--------------------------------

(Replace <your domain name> for used domain name)	

To trust the registry certificate on your Docker client, do:
	$ DOMAIN_NAME=<your domain name>:5000
	$ sudo mkdir -p /etc/docker/certs.d/$DOMAIN_NAME  	# Fill in our domain name, e.g. /etc/docker/certs.d/cvast-build.eastus.cloudapp.azure.com:5000
	$ sudo vi /etc/docker/certs.d/$DOMAIN_NAME/ca.crt 	# copy certificate from registry host to this file	
	
Restart docker daemon:
	$ sudo /etc/init.d/docker restart

	

Installation (client side, Docker for Windows < version 12.0)
-----------------------------------

(Replace <your domain name> for used domain name)

To trust the registry certificate on your Docker client, do:
	$ docker-machine ssh default
	$ DOMAIN_NAME=<your domain name>:5000
	$ sudo mkdir -p /etc/docker/certs.d/$DOMAIN_NAME
	$ sudo vi /etc/docker/certs.d/$DOMAIN_NAME/ca.crt     
	--> then copy certificate text in there

	$ sudo touch /var/lib/boot2docker/bootlocal.sh && sudo chmod +x /var/lib/boot2docker/bootlocal.sh
	$ sudo vi /var/lib/boot2docker/bootlocal.sh

Put this in bootlocal.sh:
	#!/bin/bash
	CA_CERTS_DIR=/usr/local/share/ca-certificates
	DOCKER_CERTS_DOMAIN_DIR=/etc/docker/certs.d/<your domain name>
	CERTS_DIR=/etc/ssl/certs
	CAFILE=${CERTS_DIR}/ca-certificates.crt

	cp ${DOCKER_CERTS_DOMAIN_DIR}/ca.crt ${CA_CERTS_DIR}


	for cert in $(/bin/ls -1 ${DOCKER_CERTS_DOMAIN_DIR}); do
	SRC_CERT_FILE=${CA_CERTS_DIR}/${cert}
	CERT_FILE=${CERTS_DIR}/${cert}
	HASH_FILE=${CERTS_DIR}/$(/usr/local/bin/openssl x509 -noout -hash -in ${SRC_CERT_FILE} 2>/dev/null)

	[ ! -L ${CERT_FILE} ] && /bin/ln -fs ${SRC_CERT_FILE} ${CERT_FILE}

	for idx in $(/usr/bin/seq 0 9); do
	if [ -L ${HASH_FILE}.${idx} ]; then
	[ "$(/usr/bin/readlink ${HASH_FILE}.${idx})" = "${SRC_CERT_FILE}" ] && break
	else
	/bin/ln -fs ${SRC_CERT_FILE} ${HASH_FILE}.${idx}
	break
	fi
	done
	/bin/cat ${SRC_CERT_FILE} >> ${CAFILE}
	done

	
After that, exit the ssh connection and restart boot2docker: 
docker-machine.exe restart




USAGE
-----

To connect to the registry:
	$ DOMAIN_NAME=<your domain name>:5000
	$ docker login $DOMAIN_NAME
	WARNING: login credentials saved in ~/.docker/config.json
	Login Succeeded
	$docker tag <local image name> $DOMAIN_NAME/<image name>:<version>
	$docker push $DOMAIN_NAME/<image name>:<version>


List all images:
curl -u $USERNAME:$PASSWORD --cacert ./domain.crt -X GET https://$DOMAIN_NAME/v2/_catalog

List all tags of an image (populate variable IMAGE_NAME):
IMAGE_NAME=<image name of interest>
curl -u $USERNAME:$PASSWORD --cacert ./domain.crt -X GET https://$DOMAIN_NAME/v2/$IMAGE_NAME/tags/list
