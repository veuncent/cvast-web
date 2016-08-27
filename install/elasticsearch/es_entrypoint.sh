#!/bin/bash
			
init_datadir() {
	echo "Initializing Elasticsearch data dir..."
	if [[ -d ${DATA_VOLUME} ]]; then
		# Do only if told explicitly: copies files into the persistence filesystem. (Use with caution)
		if [[ ${IS_CLEAN_ENV} == True ]]; then
			echo "Clean environment. Copying data to mounted volume..."
			if [ "$(ls -A ${DATA_VOLUME} 2>/dev/null)" ]; then
				echo "Host folder not empty. Skipping copy..."
			else
				echo "Copying ${ES_DATADIR} to ${DATA_VOLUME}"
				cp -R ${ES_DATADIR}/* ${DATA_VOLUME}			
			fi
		else
			echo "Existing environment, not copying anything to mounted volume..."
		fi
		
	else
		echo "!!! Data volume does not exist !!!"
		exit 1
	fi
}

init_configdir() {
	echo "Initializing Elasticsearch config dir..."
	if [[ -d ${CONFIG_VOLUME} ]]; then
		echo "Copying elasticsearch.yml to ${CONFIG_VOLUME}, preserving permissions"
		cp -p ${INSTALL_DIR}/elasticsearch.yml ${CONFIG_VOLUME}/elasticsearch.yml
	else
		echo "!!! Data volume does not exist !!!"
		exit 1
	fi
}

configure_aws() {
	# Get EC2 host's private ip, so that Elasticsearch nodes can find each other
	AWS_PRIVATE_IP=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
	if [[ ! -z $AWS_PRIVATE_IP ]]; then 
		set -- "$@" --network.publish_host=$AWS_PRIVATE_IP
	fi
}

set_permissions() {
	# Change the ownership of ES data and home folders to elasticsearch
	chown -R elasticsearch:elasticsearch ${DATA_VOLUME}
	chown -R elasticsearch:elasticsearch ${CONFIG_VOLUME}
	chown -R elasticsearch:elasticsearch /elasticsearch
	chown -R elasticsearch:elasticsearch ${LOG_VOLUME}
}



echo "*** Initializing Elasticsearch ***"

# Add elasticsearch as command if needed (if first character provided by user is a '-', then only options are provided and not the 'elasticsearch' binary)
if [ "${1:0:1}" = '-' ]; then
        set -- /elasticsearch/bin/elasticsearch "$@"
fi

init_datadir
init_configdir
configure_aws
set_permissions

# Run elasticsearch bin as elasticsearch user
if [ "$1" = '/elasticsearch/bin/elasticsearch' ]; then
    exec sudo -u elasticsearch -- "$@"
fi 
# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"