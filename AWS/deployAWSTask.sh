#!/bin/bash

HELP_TEXT = "Arguments:
-c or --commit: GIT commit number
-i or --image: Docker image to be deployed (web, db or elasticsearch)
-e or --environment: The AWS environment to deploy on
-h or --help: Display help text"


# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )

while [[ $# -gt 1 ]]
do
	key="$1"

	case $key in
		-c|--commit)
		BUILD_NUMBER="$2"
		shift # past argument
		;;
		-i|--image)
		DOCKER_IMAGE="$2"
		shift # past argument
		;;
		-e|--environment)
		ENVIRONMENT="$2"
		shift # past argument
		;;
		-h|--help)
		display_help
		*)
		display_help        # unknown option
		;;
	esac
	shift # past argument or value
done

echo BUILD_NUMBER  = "${BUILD_NUMBER}"
echo DOCKER_IMAGE  = "${DOCKER_IMAGE}"
echo ENVIRONMENT   = "${ENVIRONMENT}"



display_help() {
	echo ${HELP_TEXT}
}

create_task_definition() {
# Create a new task definition for this build
	sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" flask-signup.json > flask-signup-v_${BUILD_NUMBER}.json
}

deploy_task_to_AWS(){
	aws ecs register-task-definition --family flask-signup --cli-input-json file://flask-signup-v_${BUILD_NUMBER}.json
}