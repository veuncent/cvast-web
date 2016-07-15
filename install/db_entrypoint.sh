#!/bin/bash
init_datadir() {
	echo "Initializing data dir..."
	if [[ -d ${DATA_VOLUME} ]]; then
		if [ "$(ls -A ${DATA_VOLUME} 2>/dev/null)" ]; then
			echo "Host folder not empty. Skipping copy..."
		else
			echo "Copying ${PG_DATADIR} to ${DATA_VOLUME}"
			cp -R ${PG_DATADIR}/* ${DATA_VOLUME}			
		fi	
		
		echo "Changing permissions of all files in ${DATA_VOLUME} to 0600"
		find ${DATA_VOLUME} -type f -exec chmod 0600 {} \;
		
		echo "Changing permissions of all folders in ${DATA_VOLUME} to 0700"
		find ${DATA_VOLUME} -type d -exec chmod 0700 {} \;
		
		echo "Changing ownership of ${DATA_VOLUME} to ${PG_USER}"
		chown -R ${PG_USER}:${PG_USER} ${DATA_VOLUME}

	else
		echo "!!! Data volume does not exist !!!"
	fi
}

init_configdir() {
	echo "Initializing config dir..."
	if [[ -d ${CONFIG_VOLUME} ]]; then
		if [ "$(ls -A ${CONFIG_VOLUME} 2>/dev/null)" ]; then
			echo "Host folder not empty. Skipping copy..."
		else
			echo "Copying ${PG_CONFIGDIR} to ${CONFIG_VOLUME}"
			cp -R ${PG_CONFIGDIR}/* ${CONFIG_VOLUME}
		fi	
		
		echo "Changing permissions of all files in ${DATA_VOLUME} to 0600"
		find ${DATA_VOLUME} -type f -exec chmod 0600 {} \;
		
		echo "Changing permissions of all folders in ${DATA_VOLUME} to 0700"
		find ${DATA_VOLUME} -type d -exec chmod 0700 {} \;
		
		echo "Setting ownership and permissions on ${CONFIG_VOLUME}"
		chown -R ${PG_USER}:${PG_USER} ${CONFIG_VOLUME}
		chown root:root ${CONFIG_VOLUME}/postgresql.conf
        chown root:root ${CONFIG_VOLUME}/pg_hba.conf
		chmod 666 ${CONFIG_VOLUME}/postgresql.conf
		chmod 666 ${CONFIG_VOLUME}/pg_hba.conf
	else
		echo "!!! Data volume does not exist !!!"
	fi
}

init_logdir() {
	echo "Initializing log dir..."
	if [[ -d ${LOG_VOLUME} ]]; then
		echo "Changing permissions of all files and folders in ${LOG_VOLUME} to 1775"
		chmod -R 1775 ${LOG_VOLUME}
		echo "Changing ownership of ${LOG_VOLUME} to root:${PG_USER}"
		chown -R root:${PG_USER} ${LOG_VOLUME}
	else
		echo "!!! Log volume does not exist !!!"
	fi
}


set_password() {
	su - ${PG_USER} &&\
	/etc/init.d/postgresql start &&\
	psql -d ${PG_DBNAME} -c "ALTER USER ${PG_USER} with encrypted password '${PG_PASSWORD}';" &&\
	/etc/init.d/postgresql stop
}

init_datadir
init_configdir
init_logdir
