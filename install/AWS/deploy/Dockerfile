# Docker image to deploy other images to AWS
FROM ubuntu:14.04

RUN apt-get update -y
RUN apt-get install -y python-dev
RUN apt-get install -y curl
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install awscli
RUN apt-get install -y jq

COPY ./deployAWSTask.sh /cvast-arches-deploy/deployAWSTask.sh

CMD ["/cvast-arches-deploy/deployAWSTask.sh"]