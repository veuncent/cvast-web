# Docker image to deploy other images to AWS
FROM ubuntu:14.04

RUN apt-get update -y  &&\
	apt-get install -y python-dev \
		curl \
		jq \
		dos2unix
	
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install awscli

COPY ./deployAWSTask.sh /cvast-arches-deploy/deployAWSTask.sh
RUN dos2unix /cvast-arches-deploy/*

ENTRYPOINT ["/cvast-arches-deploy/deployAWSTask.sh"]