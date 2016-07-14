#!/bin/bash
init_datadir() {
	echo "Initializing datadir..."
	if [ "$(ls -A ${DATA_VOLUME} 2>/dev/null)"]; then
		echo "Host folder already initialized. Skipping copy..."
	else
		echo "Copying ${PG_DATADIR} to ${DATA_VOLUME}"
		cp -R ${PG_DATADIR}/* ${DATA_VOLUME}
		if [[ -d ${DATA_VOLUME} ]]; then
			echo "Changing permissions of all files in ${DATA_VOLUME} to 0600"
			find ${DATA_VOLUME} -type f -exec chmod 0600 {} \;
			
			echo "Changing permissions of all folders in ${DATA_VOLUME} to 0700"
			find ${DATA_VOLUME} -type d -exec chmod 0700 {} \;
			
			echo "Changing ownership of ${DATA_VOLUME} to ${PG_USER}"
			chown -R ${PG_USER}:${PG_USER} ${DATA_VOLUME}
		fi	
	fi	
}

init_logdir() {
  echo "Initializing logdir..."
  chmod -R 1775 ${PG_LOGDIR}
  chown -R root:${PG_USER} ${PG_LOGDIR}
}

set_password() {
	/etc/init.d/postgresql start &&\
	psql -d postgres -c "ALTER USER ${PG_USER} with encrypted password '${DB_PASS}';" &&\
	/etc/init.d/postgresql stop
}

change_user_to_postgres() {
	echo "Switching to user ${PG_USER}"
	su - ${PG_USER}
}

init_datadir
#change_user_to_postgres