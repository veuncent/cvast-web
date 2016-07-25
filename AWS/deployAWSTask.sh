#!/bin/bash

IMAGE_OPTIONS="db|web|elasticsearch"
ENVIRONMENT_OPTIONS="test"
HELP_TEXT="
Arguments:
-c or --commit: GIT commit number
-i or --image: Docker image to be deployed (options: ${IMAGE_OPTIONS})
-e or --environment: The AWS environment to deploy on (options: ${ENVIRONMENT_OPTIONS})
-h or --help: Display help text
"

TMP_FOLDER=./tmp



display_help() {
	echo ${HELP_TEXT}
}

create_task_definition() {
	# Create tmp folder if it doesn't exist
	[ -d ${TMP_FOLDER} ] || mkdir ${TMP_FOLDER}
	# Create a new task definition for this build
	# sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" ./task-definition-${DOCKER_IMAGE}-${ENVIRONMENT}.json > ${TMP_FOLDER}/task-definition-${DOCKER_IMAGE}-${ENVIRONMENT}_${BUILD_NUMBER}.json
	sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" ./task-definition-${DOCKER_IMAGE}-${ENVIRONMENT}.json > ${TMP_FOLDER}/task-definition-${DOCKER_IMAGE}-${ENVIRONMENT}_${BUILD_NUMBER}.json

}

register_task_definition_in_AWS(){
	echo "Registering ${TMP_FOLDER}/task-definition-${DOCKER_IMAGE}-${ENVIRONMENT}_${BUILD_NUMBER}.json on AWS"
	aws ecs register-task-definition --family ${TASK_FAMILY} --cli-input-json file://${TMP_FOLDER}/task-definition-${DOCKER_IMAGE}-${ENVIRONMENT}_${BUILD_NUMBER}.json
}

update_AWS_service_with_task_revision(){
	TASK_REVISION=`aws ecs describe-task-definition --task-definition ${TASK_FAMILY} | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`
	echo "Updating task ${TASK_FAMILY} on AWS service ${SERVICE_NAME} with task revision ${TASK_REVISION}"
	aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION}
}

cleanup() {
	echo "Removing ${TMP_FOLDER}/task-definition-${DOCKER_IMAGE}-${ENVIRONMENT}_${BUILD_NUMBER}.json"
	rm ${TMP_FOLDER}/task-definition-${DOCKER_IMAGE}-${ENVIRONMENT}_${BUILD_NUMBER}.json
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
		-i|--image)
			DOCKER_IMAGE="$2"
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

eval "case ${DOCKER_IMAGE} in
	${IMAGE_OPTIONS})
		echo "Deploying image: ${DOCKER_IMAGE}"
		;;
	*)			# Any other input-json
		echo "Invalid Docker image option: ${DOCKER_IMAGE}"
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


TASK_FAMILY=cvast-arches-${DOCKER_IMAGE}-task-${ENVIRONMENT}
CLUSTER_NAME=cvast-arches-cluster-${ENVIRONMENT}
SERVICE_NAME=cvast-arches-${DOCKER_IMAGE}-service-${ENVIRONMENT}

create_task_definition
register_task_definition_in_AWS
update_AWS_service_with_task_revision
cleanup


