#!/bin/bash

HELP_TEXT="

============== CVAST Web help ==============

Commands:  
	run_web: Default. First collect static files, then run the Django web server
	collect_static: Let Django collect static files
	run_migrations: Run database migrations
	create_superuser: Create a Django superuser
	init_environment: Set up the database by running Django migrations and creating a superuser
	help | -h | --help: Display help text  

"

display_help() {
	echo "${HELP_TEXT}"
}




### Functions

run_sql_statement_on_server() {
	local statement=$1
	mysql --user=root --password=${DBPASSWORD} --host=${DBHOST} --port=${DBPORT} -e "${statement}"
}

run_sql_statement_on_database() {
	local statement=$1
	mysql --user=root --password=${DBPASSWORD} --host=${DBHOST} --port=${DBPORT} --database=${DBNAME} -e "${statement}"
}

wait_for_db() {
	echo "Waiting for database connection..."
	while [[ ! ${return_code} == 0 ]]
	do
		mysql -uroot -p${DBPASSWORD} -h ${DBHOST} --port=${DBPORT} -e "show databases" >&/dev/null
		return_code=$?
		sleep 1
	done
	echo "Database server is up"
}


handle_exit_code() {
	local return_code=$1
	if [[ ${return_code} == 0 ]]; then
		echo "[Done]"
	else
		echo "[Failed]"
		exit ${return_code}
	fi
}


### Commands 


run_django_server() {
	echo ""
	echo ""
	echo "----- *** RUNNING DJANGO SERVER *** -----"
	echo ""
	if [[ ${DJANGO_REMOTE_DEBUG} == "True" ]]; then
		echo "[Info] Running Django server with --noreload setting"
		exec python ${WEB_ROOT}/manage.py runserver --noreload --nothreading 0.0.0.0:8000
	else
		exec python ${WEB_ROOT}/manage.py runserver 0.0.0.0:8000
	fi
}


collect_static() {
	echo ""
	echo ""
	echo "----- COLLECTING DJANGO STATIC FILES -----"
	echo ""
	python ${WEB_ROOT}/manage.py collectstatic --noinput
	handle_exit_code $?	
}


setup_db() {
	echo ""
	echo ""
	echo "----- CREATING DATABASE IF IT DOES NOT EXISTS -----"
	echo ""	
	run_sql_statement_on_server "CREATE DATABASE IF NOT EXISTS ${DBNAME}";
	handle_exit_code $?
}


run_migrations() {
	local arguments="$@"
	echo ""
	echo ""
	echo "----- RUNNING DATABASE MIGRATIONS -----"
	echo ""
	python ${WEB_ROOT}/manage.py migrate ${arguments}
	handle_exit_code $?	
}


create_superuser() {
	echo ""
	echo ""
	echo "----- CREATING DJANGO SUPERUSER -----"
	echo ""
	python ${WEB_ROOT}/manage.py init_admin
	handle_exit_code $?	
}


init_pages() {
	echo ""
	echo ""
	echo "----- CREATING DUMMY PAGES -----"
	echo ""
	python ${WEB_ROOT}/manage.py init_pages
	handle_exit_code $?	
}


init_environment() {
	echo ""
	echo ""
	echo "*** INITIALIZING ENVIRONMENT ***"
	setup_db
	run_migrations
	create_superuser
	init_pages
	collect_static
}



### Starting point ###


# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it, such as --help ).

# If no arguments are supplied, assume the server needs to be run
if [[ $#  -eq 0 ]]; then
	display_help
	exit 0
fi

# Else, process arguments
full_command="$@"
arguments="${@:2}"
command="$1"
echo "Command: ${full_command}"


case ${command} in
	run_web)
		wait_for_db
		collect_static
		run_django_server
	;;
	collect_static)
		collect_static
	;;
	run_migrations)
		wait_for_db
		run_migrations ${arguments}
	;;
	create_superuser)
		wait_for_db
		create_superuser
	;;
	init_pages)
		wait_for_db
		init_pages
	;;
	setup_db)
		wait_for_db
		setup_db
	;;
	init_environment)
		wait_for_db
		init_environment
	;;
	help|-h|--help)
		display_help
	;;
	*)
		exec "$@"
	;;
esac
