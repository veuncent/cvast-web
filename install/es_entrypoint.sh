#!/bin/bash
init_configdir() {
	echo "Initializing Elasticsearch config dir..."
	if [[ -d ${CONFIG_VOLUME} ]]; then
		if [ "$(ls -A ${CONFIG_VOLUME} 2>/dev/null)" ]; then
			echo "Host folder not empty. Skipping copy..."
		else
			echo "Copying elasticsearch.yml to ${CONFIG_VOLUME}, preserving permissions"
			cp -p /tmp/elasticsearch.yml ${CONFIG_VOLUME}/elasticsearch.yml
		fi	
	else
		echo "!!! Data volume does not exist !!!"
	fi
}
