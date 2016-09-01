#!/bin/bash



### Global variables

PREVIOUS_BUILD=`expr $BUILD_NUMBER - 1`
OLD_IMAGE_BUILD=`expr $BUILD_NUMBER - 7` # For cleaning up old junk



####Functions####################################################################################################################


# Parameters: 
# $1 = app (web, db, elasticsearch, nginx)
build_image() {
	echo "Building Docker image:  $1:$BUILD_NUMBER"
	sudo docker build -f Dockerfile-$1 -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-$1:$BUILD_NUMBER .
}


# Parameters: 
# $1 = app (web, db, elasticsearch, nginx)
# Cleanup old images, keep latest 7
cleanup_old_image() {
	if [[ $(sudo docker images -q cvast-build.eastus.cloudapp.azure.com:5000/cvast-$1:$OLD_IMAGE_BUILD 2> /dev/null ) ]]; then
		echo "Removing old image:  $1:$OLD_IMAGE_BUILD"
		sudo docker rmi cvast-build.eastus.cloudapp.azure.com:5000/cvast-$1:$OLD_IMAGE_BUILD
	fi
}


# Parameters: 
# $1 = app (web, db, elasticsearch, nginx)
push_to_registry() {
	echo "Pushing to private Docker registry:  $1:$BUILD_NUMBER "
	sudo docker push cvast-build.eastus.cloudapp.azure.com:5000/cvast-$1:$BUILD_NUMBER
}


# parameters: 
# $1 = app (web, db, elasticsearch, nginx)
deploy_image() {
	# See if old image exists.
	if [[ $(sudo docker images -q cvast-build.eastus.cloudapp.azure.com:5000/cvast-$1:$PREVIOUS_BUILD 2> /dev/null) ]]; then
		local OLD_IMAGE=`sudo docker images -q cvast-build.eastus.cloudapp.azure.com:5000/cvast-$1:$PREVIOUS_BUILD`
	fi
	
	local NEW_IMAGE=`sudo docker images -q cvast-build.eastus.cloudapp.azure.com:5000/cvast-$1:$BUILD_NUMBER`
	
	# Deploy only if there are no older images or if older image is different. Efficiency!
	if [[ -z $OLD_IMAGE ]] || [[ "$OLD_IMAGE" != "$NEW_IMAGE" ]]; then
		echo "Deploying to AWS:  $1:$BUILD_NUMBER"
		sudo docker run cvast-build.eastus.cloudapp.azure.com:5000/cvast-arches-deploy -c $BUILD_NUMBER -e test -a $1
	fi
}


#################################################################################################################################



### Build all images
sudo docker build -f Dockerfile-arches-complete -t cvast-build.eastus.cloudapp.azure.com:5000/arches-complete .
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
sudo docker-compose up --force-recreate &
sleep 5 && echo "5"
sleep 5 && echo "10"
sleep 5 && echo "15"
sleep 5 && echo "20"
sleep 5 && echo "25"
sleep 5 && echo "30"
echo "Stopping all Docker containers..."
sudo docker-compose down



### Push all images to Docker Private Registry
push_to_registry web
push_to_registry db
push_to_registry elasticsearch
push_to_registry nginx



### Deploy to AWS
sudo docker pull cvast-build.eastus.cloudapp.azure.com:5000/cvast-arches-deploy
deploy_image web
deploy_image nginx
deploy_image db
deploy_image elasticsearch
