
init_datadir() {
  echo "Initializing datadir..."
  if [[ -d ${PG_DATADIR} ]]; then
    find ${PG_DATADIR} -type f -exec chmod 0600 {} \;
    find ${PG_DATADIR} -type d -exec chmod 0700 {} \;
  fi
  chown -R ${PG_USER}:${PG_USER} ${PG_HOME}
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

init_datadir()