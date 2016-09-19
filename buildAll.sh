#!/bin/bash
docker build -t cvast-build.eastus.cloudapp.azure.com:5000/arches-complete -f Dockerfile-arches-complete . 
docker build -f Dockerfile-web -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-web ./
docker build -f Dockerfile-db -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-db ./
docker build -f Dockerfile-elasticsearch -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-elasticsearch ./
docker build -f Dockerfile-nginx -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-nginx ./