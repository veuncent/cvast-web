FROM python:2.7
USER root

# Install dependencies
RUN apt-get update -y &&\
	apt-get upgrade -y &&\
	apt-get update -y &&\
	apt-get install -y dos2unix



RUN pip install 'Django==1.11' requests

# Setting default environment variables
ENV DJANGO_PROJECT_NAME=cvast_web
ENV WEB_ROOT=/${DJANGO_PROJECT_NAME}
ENV DOCKER_DIR=/docker

COPY ${DJANGO_PROJECT_NAME} ${WEB_ROOT}
WORKDIR ${WEB_ROOT}


# Entrypoint to setup volume mounts
COPY docker/entrypoint.sh ${DOCKER_DIR}/entrypoint.sh
RUN chmod -R 700 ${DOCKER_DIR}
RUN dos2unix ${DOCKER_DIR}/*


CMD ${DOCKER_DIR}/entrypoint.sh