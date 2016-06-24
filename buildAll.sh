#!/bin/bash
sudo docker build -f Dockerfile-arches-complete -t cvast/arches-complete ./ 
sudo docker build -f Dockerfile-web -t cvast/cvast-web ./
sudo docker build -f Dockerfile-db -t cvast/cvast-db ./
sudo docker build -f Dockerfile-elasticsearch -t cvast/cvast-elasticsearch ./