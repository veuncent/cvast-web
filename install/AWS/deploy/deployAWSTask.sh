#!/bin/bash

APP_OPTIONS="db|web|elasticsearch"
ENVIRONMENT_OPTIONS="test|acc"
HELP_TEXT="
Arguments:
-c or --commit: GIT commit number
-a or --app: CVAST app to be deployed (options: ${APP_OPTIONS})
-e or --environment: The AWS environment to deploy on (options: ${ENVIRONMENT_OPTIONS})
-h or --help: Display help text
"


display_help() {
	echo ${HELP_TEXT}
}

create_task_definition() {
	LATEST_TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition ${TASK_FAMILY})
	echo $LATEST_TASK_DEFINITION \
		| jq '{containerDefinitions: .taskDefinition.containerDefinitions, volumes: .taskDefinition.volumes}' \
		| jq '.containerDefinitions[0].image='\"${DOCKER_IMAGE}\" \
		> ${TMP_FOLDER}/tmp.json
}

register_task_definition_in_AWS(){
	echo "Registering task definition for ${DOCKER_IMAGE} on AWS"
	sudo aws ecs register-task-definition --family ${TASK_FAMILY} --cli-input-json file://${TMP_FOLDER}/tmp.json
}

update_AWS_service_with_task_revision(){
	TASK_REVISION=`sudo aws ecs describe-task-definition --task-definition ${TASK_FAMILY} | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`
	echo "Updating task ${TASK_FAMILY} on AWS service ${SERVICE_NAME} with task revision ${TASK_REVISION}"
	sudo aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION}
}




### Enter here (parameter check) ###

# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it, such as --help ).

while [[ $# -gt 0 ]]
do
	key="$1"

	case ${key} in
		-c|--commit)
			BUILD_NUMBER="$2"
			shift # next argument
		;;
		-a|--app)
			CVAST_APP="$2"
			shift # next argument
		;;
		-e|--environment)
			ENVIRONMENT="$2"
			shift # next argument
		;;
		-h|--help)
			display_help
			exit 0
		;;
		*)
			echo "Unknown option: ${key}"
			display_help
			exit 1
		;;
	esac
	shift # next argument or value
done

eval "case ${CVAST_APP} in
	${APP_OPTIONS})
		echo "Deploying image: ${CVAST_APP}"
		;;
	*)			# Any other input-json
		echo "Invalid Docker image option: ${CVAST_APP}"
		display_help
		exit 1
		;;
esac"

eval "case ${ENVIRONMENT} in
	${ENVIRONMENT_OPTIONS})
		echo "Deploying on environment: ${ENVIRONMENT}"
		;;
	*)			# Any other input-json
		echo "Invalid environment option: ${ENVIRONMENT}"
		display_help
		exit 1
		;;
esac"

if [ -z ${BUILD_NUMBER} ] || [ -z ${CVAST_APP} ] || [ -z ${ENVIRONMENT} ] ; then
        echo "ERROR! Not all parameters were specified. Exiting..."
		display_help
        exit 1
	fi

### Env variables
TASK_FAMILY=${ENVIRONMENT}-cvast-arches-${CVAST_APP}-task
CLUSTER_NAME=${ENVIRONMENT}-cvast-arches-cluster
SERVICE_NAME=${ENVIRONMENT}-cvast-arches-${CVAST_APP}-service
DOCKER_IMAGE=cvast-build.eastus.cloudapp.azure.com:5000/cvast-${CVAST_APP}:${BUILD_NUMBER}
TMP_FOLDER=./tmp

### Do things
[ -d ${TMP_FOLDER} ] || mkdir ${TMP_FOLDER}		# Create tmp folder if it doesn't exist
create_task_definition
register_task_definition_in_AWS
update_AWS_service_with_task_revision
echo "Done."

