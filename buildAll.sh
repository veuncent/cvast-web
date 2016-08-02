#!/bin/bash
sudo docker build -t cvast-build.eastus.cloudapp.azure.com:5000/arches-complete -f Dockerfile-arches-complete . 
sudo docker build -f Dockerfile-web -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-web ./
sudo docker build -f Dockerfile-db -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-db ./
sudo docker build -f Dockerfile-elasticsearch -t cvast-build.eastus.cloudapp.azure.com:5000/cvast-elasticsearch ./