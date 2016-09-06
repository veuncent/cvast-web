#!/bin/bash
set_password() {
	if [[ ${IS_CLEAN_ENV} == True ]]; then
		echo "Clean environment. Setting Django password..."
		cd ${WEB_ROOT}/${WEB_APP_NAME}
		python manage.py setPassword
	else
		echo "Existing environment, not setting Django password..."
	fi
}

run_django_server() {
	exec python ${WEB_ROOT}/${WEB_APP_NAME}/manage.py runserver 0.0.0.0:8000
}


### Starting point ### 

echo "*** Initializing Django ***"
set_password

echo "*** Running Django server ***"
run_django_server