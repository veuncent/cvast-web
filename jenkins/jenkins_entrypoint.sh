#!/bin/bash

sudo chmod 755 /usr/bin/docker

exec /bin/tini -- /usr/local/bin/jenkins.sh