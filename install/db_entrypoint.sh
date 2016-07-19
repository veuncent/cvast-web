#!/bin/bash
init_datadir() {
	echo "Initializing data dir..."
	if [[ -d ${DATA_VOLUME} ]]; then
		# Do only if told explicitly: copies files into the persistence filesystem. (Use with caution)
		if [[ ${IS_CLEAN_ENV} == true ]]; then
			if [ "$(ls -A ${DATA_VOLUME} 2>/dev/null)" ]; then
				echo "Host folder not empty. Skipping copy..."
			else
				echo "Copying ${PG_DATADIR} to ${DATA_VOLUME}"
				cp -R ${PG_DATADIR}/* ${DATA_VOLUME}			
			fi	
		fi
		
		echo "Changing permissions of all files in ${DATA_VOLUME} to 0600"
		find ${DATA_VOLUME} -type f -exec chmod 0600 {} \;
		echo "Changing permissions of all folders in ${DATA_VOLUME} to 0700"
		find ${DATA_VOLUME} -type d -exec chmod 0700 {} \;
		echo "Changing ownership of ${DATA_VOLUME} to postgres"
		chown -R postgres:postgres ${DATA_VOLUME}

	else
		echo "!!! Data volume does not exist !!!"
		exit 1
	fi
}

init_configdir() {
	echo "Initializing config dir..."
	if [[ -d ${CONFIG_VOLUME} ]]; then
		# Do only if told explicitly: copies files into the persistence filesystem. (Use with caution)
		if [[ ${IS_CLEAN_ENV} == true ]]; then
			if [ "$(ls -A ${CONFIG_VOLUME} 2>/dev/null)" ]; then
				echo "Host folder not empty. Skipping copy..."
			else
				echo "Copying ${PG_CONFIGDIR} to ${CONFIG_VOLUME}"
				cp -R ${PG_CONFIGDIR}/* ${CONFIG_VOLUME}
			fi	
		fi
		
		echo "Setting ownership and permissions on ${CONFIG_VOLUME}"
		chown -R postgres:postgres ${CONFIG_VOLUME}
		chown root:root ${CONFIG_VOLUME}/postgresql.conf
        chown root:root ${CONFIG_VOLUME}/pg_hba.conf
		chmod 666 ${CONFIG_VOLUME}/postgresql.conf
		chmod 666 ${CONFIG_VOLUME}/pg_hba.conf
	else
		echo "!!! Config volume does not exist !!!"
		exit 1
	fi
}

init_logdir() {
	echo "Initializing log dir..."
	if [[ -d ${LOG_VOLUME} ]]; then
		echo "Changing permissions of all files and folders in ${LOG_VOLUME} to 1775"
		chmod -R 1775 ${LOG_VOLUME}
		echo "Changing ownership of ${LOG_VOLUME} to root:postgres"
		chown -R root:postgres ${LOG_VOLUME}
	else
		echo "!!! Log volume does not exist !!!"
		exit 1
	fi
}


set_password() {
	echo "Setting database password for user postgres"
	${PG_BINDIR}/postgresql start &&\
	psql -U postgres -d postgres -c "ALTER USER postgres with encrypted password '${PG_PASSWORD}';" &&\
	${PG_BINDIR}/postgresql stop
}

check_env_variables(){
	if [[ -z ${PG_PASSWORD} ]]; then
        echo "ERROR! Please specify a password for postgres in PG_PASSWORD. Exiting..."
        exit 1
	fi
}

check_env_variables
init_datadir
init_configdir
init_logdir

set_password
