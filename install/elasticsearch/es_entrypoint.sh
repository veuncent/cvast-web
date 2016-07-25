#!/bin/bash

	
			
init_datadir() {
	echo "Initializing Elasticsearch data dir..."
	if [[ -d ${DATA_VOLUME} ]]; then
		# Do only if told explicitly: copies files into the persistence filesystem. (Use with caution)
		if [[ ${IS_CLEAN_ENV} == true ]]; then
			echo "Clean environment. Copying to mounted volume..."
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
		# Do only if told explicitly: copies files into the persistence filesystem. (Use with caution)
		if [[ ${IS_CLEAN_ENV} == true ]]; then
			echo "Clean environment. Copying to mounted volume..."
			if [ "$(ls -A ${CONFIG_VOLUME} 2>/dev/null)" ]; then
				echo "Host folder not empty. Skipping copy..."
			else
				echo "Copying elasticsearch.yml to ${CONFIG_VOLUME}, preserving permissions"
				cp -p ${INSTALL_DIR}/elasticsearch.yml ${CONFIG_VOLUME}/elasticsearch.yml
			fi	
		else
			echo "Existing environment, not copying anything to mounted volume..."
		fi
	else
		echo "!!! Data volume does not exist !!!"
		exit 1
	fi
}

echo "*** Initializing Elasticsearch ***"
 
init_datadir
init_configdir