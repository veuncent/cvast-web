#!/bin/bash
docker rm $(docker ps -q -f status=exited)

docker rmi $(docker images -q -f dangling=true)

# Remove dangling volumes (carefull...)
# docker volume rm $(docker volume ls -qf dangling=true)