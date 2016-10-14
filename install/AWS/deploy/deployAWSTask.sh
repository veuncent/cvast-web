#!/bin/bash

APP_OPTIONS="db|web|elasticsearch|nginx|potree|potree-sync"
ENVIRONMENT_OPTIONS="test|acc"
HELP_TEXT="
Arguments:
-c or --commit: GIT commit number
-a or --app: CVAST app to be deployed (options: ${APP_OPTIONS})
-e or --environment: The AWS environment to deploy on (options: ${ENVIRONMENT_OPTIONS})
-h or --help: Display help text

This Docker image requires the following environment variables in order to run:
--env AWS_ACCESS_KEY_ID
--env AWS_SECRET_ACCESS_KEY
--env AWS_DEFAULT_REGION
"



### Functions
# configure_aws() {
	# sudo aws configure | 
# }

display_help() {
	echo "${HELP_TEXT}"
}

create_task_definition() {
echo "Creating new AWS ECS task definition..."
	LATEST_TASK_DEFINITION=$(aws ecs describe-task-definition --region ${AWS_DEFAULT_REGION} --task-definition ${TASK_FAMILY})
		 
	echo $LATEST_TASK_DEFINITION \
		| jq --arg docker_image "${DOCKER_IMAGE}" \
			--arg container_name "${CONTAINER_NAME}" \
			'{containerDefinitions: .taskDefinition.containerDefinitions, volumes: .taskDefinition.volumes}
			| .containerDefinitions=(.containerDefinitions
				| map(if (.name == $container_name)
					then .image=$docker_image
					else .
				end)
			)' > ${TMP_FOLDER}/tmp.json
}

register_task_definition_in_AWS(){
	echo "Registering new task definition for ${DOCKER_IMAGE} on AWS..."
	aws ecs register-task-definition --region ${AWS_DEFAULT_REGION} --family ${TASK_FAMILY} --cli-input-json file://${TMP_FOLDER}/tmp.json
}

# Update the AWS ECS service to use the new task definition
update_AWS_service_with_task_revision(){
	TASK_REVISION=$(aws ecs describe-task-definition --region ${AWS_DEFAULT_REGION} --task-definition ${TASK_FAMILY} | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//')
	echo "Updating task ${TASK_FAMILY} on AWS service ${SERVICE_NAME} with task revision ${TASK_REVISION}..."
	aws ecs update-service --region ${AWS_DEFAULT_REGION} --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION}
}



### Enter here (parameter check) ###

# Global variables (parsed through Docker run command)
if [[ -z ${AWS_ACCESS_KEY_ID} ]]; then
	echo "Environment variable AWS_ACCESS_KEY_ID not specified, exiting..."
	exit 1
fi

if [[ -z ${AWS_SECRET_ACCESS_KEY} ]]; then
	echo "Environment variable AWS_SECRET_ACCESS_KEY not specified, exiting..."
	exit 1
fi

if [[ -z ${AWS_DEFAULT_REGION} ]]; then
	echo "Environment variable AWS_DEFAULT_REGION not specified, exiting..."
	exit 1
fi

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
	*)			
		# Any other input
		echo "Invalid Docker image option: ${CVAST_APP}"
		display_help
		exit 1
		;;
esac"

eval "case ${ENVIRONMENT} in
	${ENVIRONMENT_OPTIONS})
		echo "Deploying on environment: ${ENVIRONMENT}"
		;;
	*)			
		# Any other input
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
if [[ ${CVAST_APP} == "web" ]] || [[ ${CVAST_APP} == "nginx" ]] || [[ ${CVAST_APP} == "elasticsearch" ]] || [[ ${CVAST_APP} == "db" ]]; then
	PREFIX="-arches"
fi

DOCKER_IMAGE=cvast/cvast-${CVAST_APP}:${BUILD_NUMBER}
CONTAINER_NAME=${ENVIRONMENT}-cvast${PREFIX}-${CVAST_APP}-container

# Nginx is part of the web task and service
if [[ ${CVAST_APP} == 'nginx' ]]; then
	CVAST_APP='web'
# potree-sync is part of the potree task and service, but uses the cvast-potree Docker image (no separate image for potree-sync)
elif [[ ${CVAST_APP} == 'potree-sync' ]]; then
	CVAST_APP='potree'
	DOCKER_IMAGE=cvast/cvast-${CVAST_APP}:${BUILD_NUMBER}
fi

TASK_FAMILY=${ENVIRONMENT}-cvast${PREFIX}-${CVAST_APP}-task
SERVICE_NAME=${ENVIRONMENT}-cvast${PREFIX}-${CVAST_APP}-service
CLUSTER_NAME=${ENVIRONMENT}-cvast-arches-cluster
TMP_FOLDER=./tmp

### Do things
[ -d ${TMP_FOLDER} ] || mkdir ${TMP_FOLDER}		# Create tmp folder if it doesn't exist
create_task_definition
register_task_definition_in_AWS
update_AWS_service_with_task_revision
echo "Done."

