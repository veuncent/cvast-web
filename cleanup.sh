#!/bin/bash
if [[ $(docker ps -q -f status=exited) ]]; then
	docker rm $(docker ps -q -f status=exited)
fi

if [[ $(docker ps -a | grep "Created") ]]; then
	docker rm $(docker ps -a | grep "Created" | awk '{print $1}')
fi

if [[ $(docker images -q -f dangling=true) ]]; then
	docker rmi $(docker images -q -f dangling=true)
fi

# Remove dangling volumes (carefull...)
# docker volume rm $(docker volume ls -qf dangling=true)