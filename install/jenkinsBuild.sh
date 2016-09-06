#!/bin/bash



### Global variables and Help

APP_OPTIONS="db|web|elasticsearch|nginx"
DEFAULT_APPS_DEPLOYED="web|nginx"
ENVIRONMENT_OPTIONS="test|acc"

HELP_TEXT="
Arguments:  
-a or --app: Optional: CVAST app to be deployed, multiple allowed within quotes "" (options: ${APP_OPTIONS}). If --app not specified, these apps are deployed: ${DEFAULT_APPS_DEPLOYED}  
-e or --environment: The AWS environment to deploy on (options: ${ENVIRONMENT_OPTIONS})
-c or --commit: The build / commit number to tag the images with (e.g. the \$BUILD_NUMBER variable in Jenkins)
-i or --access_key_id: The AWS Access Key ID of your AWS account  
-k or --secret_access_key: The AWS Secret Access Key of your AWS account  
-h or --help: Display help text  
"

AWS_DEFAULT_REGION=us-east-1



	
####Functions####################################################################################################################


# Parameters: 
# $1 = app (web, db, elasticsearch, nginx)
build_image() {
	local APP_NAME=$1
	echo "Building Docker image:  $APP_NAME:$BUILD_NUMBER"
	docker build -f Dockerfile-$APP_NAME -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-$APP_NAME:$BUILD_NUMBER .
}


# Parameters: 
# $1 = app (web, db, elasticsearch, nginx)
# Cleanup old images, keep latest 7
cleanup_old_image() {
	local APP_NAME=$1
	if [[ $(docker images -q cvast-build.eastus.cloudapp.azure.com:5000/cvast-$APP_NAME:$OLD_IMAGE_BUILD 2> /dev/null ) ]]; then
		echo "Removing old image:  $APP_NAME:$OLD_IMAGE_BUILD"
		docker rmi cvast-build.eastus.cloudapp.azure.com:5000/cvast-$APP_NAME:$OLD_IMAGE_BUILD
	fi
}


# Parameters: 
# $1 = app (web, db, elasticsearch, nginx)
push_to_registry() {
	local APP_NAME=$1
	echo "Pushing to private Docker registry:  $APP_NAME:$BUILD_NUMBER "
	docker push cvast-build.eastus.cloudapp.azure.com:5000/cvast-$APP_NAME:$BUILD_NUMBER
}


# parameters: 
# $1 = app (web, db, elasticsearch, nginx)
prepare_deploy_image() {
	local APP_NAME=$1
	# See if old image exists.
	if [[ $(docker images -q cvast-build.eastus.cloudapp.azure.com:5000/cvast-$APP_NAME:$PREVIOUS_BUILD 2> /dev/null) ]]; then
		local OLD_IMAGE=`docker images -q cvast-build.eastus.cloudapp.azure.com:5000/cvast-$APP_NAME:$PREVIOUS_BUILD`
	fi
	
	local NEW_IMAGE=`docker images -q cvast-build.eastus.cloudapp.azure.com:5000/cvast-$APP_NAME:$BUILD_NUMBER`
	
	# Test if deployment is forced through script parameters
	if [[ ! -z $DEPLOY_THESE_APPS ]]; then 
		if [[ $(array_contains_element $APP_NAME $DEPLOY_THESE_APPS) ]]; then
			deploy_image $APP_NAME
		fi
	# Else, deploy only if there are no older images or if older image is different. Efficiency!
	elif [[ $(array_contains_element $APP_NAME $DEFAULT_APPS_DEPLOYED) ]] && ([[ -z $OLD_IMAGE ]] || [[ "$OLD_IMAGE" != "$NEW_IMAGE" ]]) ; then
		deploy_image $APP_NAME
	fi
}


# parameters: 
# $1 = app (web, db, elasticsearch, nginx)
deploy_image() {
	echo "Deploying to AWS:  $APP_NAME:$BUILD_NUMBER"
	docker run \
		--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		--env AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		cvast-build.eastus.cloudapp.azure.com:5000/cvast-arches-deploy \
		-c $BUILD_NUMBER -e ${ENVIRONMENT} -a $APP_NAME
}


# Check if value is in array
array_contains_element() {
	local e
	for e in "${@:2}"; do 
		[[ "$e" == "$1" ]] && return 0; 
	done
	return 1
}

display_help() {
	echo ${HELP_TEXT}
}

#################################################################################################################################



### Actual execution

# Script parameters 

# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it, such as --help ).

while [[ $# -gt 0 ]]
do
	key="$1"

	case ${key} in
		-a|--app)
			IFS=' ' read -r -a DEPLOY_THESE_APPS <<< "$2"
			# DEPLOY_THESE_APPS=("$2");
			shift; # next argument
		;;
		-e|--environment)
			ENVIRONMENT="$2"
			shift # next argument
		;;
		-c|--commit)
			BUILD_NUMBER="$2"
			shift # next argument
		;;
		-i|--access_key_id)
			AWS_ACCESS_KEY_ID="$2"
			shift # next argument
		;;
		-k|--secret_access_key)
			AWS_SECRET_ACCESS_KEY="$2"
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

if [[ ! -z ${DEPLOY_THESE_APPS} ]]; then
	for app in "${DEPLOY_THESE_APPS[@]}"; do
		eval "case ${app} in
			${APP_OPTIONS})
				echo \"Processing image: ${app}\"
				;;
			*)			
				# Any other input
				echo \"Invalid option: -a|--app: ${app}\"
				display_help
				exit 1
				;;
		esac"
	done 
fi



if [[ -z ${ENVIRONMENT} ]] ; then
	echo "ERROR! -e|--environment parameter not specified. Exiting..."
	display_help
	exit 1
fi

eval "case ${ENVIRONMENT} in
	${ENVIRONMENT_OPTIONS})
		echo \"Deploying on environment: ${ENVIRONMENT}\"
		;;
	*)			
		# Any other input
		echo \"Invalid option: -e|--environment ${ENVIRONMENT}\"
		display_help
		exit 1
		;;
esac"

if [[ -z ${BUILD_NUMBER} ]] ; then
	echo "ERROR! -c|--commit parameter not specified. Exiting..."
	display_help
	exit 1
else
	PREVIOUS_BUILD=`expr $BUILD_NUMBER - 1`
	OLD_IMAGE_BUILD=`expr $BUILD_NUMBER - 7` # For cleaning up old junk
fi


if [[ -z ${AWS_ACCESS_KEY_ID} ]] ; then
	echo "ERROR! -i|--access_key_id parameter not specified. Exiting..."
	display_help
	exit 1
fi

if [[ -z ${AWS_SECRET_ACCESS_KEY} ]] ; then
	echo "ERROR! -k|--secret_access_key parameter not specified. Exiting..."
	display_help
	exit 1
fi


	
### Build all images
docker build -f Dockerfile-arches-complete -t cvast-build.eastus.cloudapp.azure.com:5000/arches-complete .
build_image web
build_image db
build_image elasticsearch
build_image nginx



### Cleanup old images, keep latest 7
cleanup_old_image web
cleanup_old_image db
cleanup_old_image elasticsearch
cleanup_old_image nginx



### Run all containers (unit tests to be added)
echo "Starting all Docker containers..."
docker-compose up --force-recreate &
sleep 5 && echo "5"
sleep 5 && echo "10"
sleep 5 && echo "15"
sleep 5 && echo "20"
sleep 5 && echo "25"
sleep 5 && echo "30"
echo "Stopping all Docker containers..."
docker-compose down



### Push all images to Docker Private Registry
push_to_registry web
push_to_registry db
push_to_registry elasticsearch
push_to_registry nginx



### Deploy to AWS
docker pull cvast-build.eastus.cloudapp.azure.com:5000/cvast-arches-deploy
deploy_image web
deploy_image nginx
# deploy_image db
# deploy_image elasticsearch
