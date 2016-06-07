#!/bin/bash
docker build -f Dockerfile-arches-complete -t cvast/arches-complete ./ 
docker build -f Dockerfile-web -t cvast/cvast-web ./
docker build -f Dockerfile-db -t cvast/cvast-db ./
docker build -f Dockerfile-elasticsearch -t cvast/cvast-elasticsearch ./