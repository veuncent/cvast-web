#!/bin/bash

sudo chmod 755 /usr/bin/docker
sudo chmod 755 /var/jenkins_home/.docker/config.json
sudo chmod 777 /var/run/docker.sock

exec /bin/tini -- /usr/local/bin/jenkins.sh