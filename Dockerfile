FROM python:2.7
USER root

# Setting default environment variables
ENV DJANGO_PROJECT_NAME=cvast_web
ENV WEB_ROOT=/${DJANGO_PROJECT_NAME}
ENV DOCKER_DIR=/docker
ENV INSTALL_DIR=/install

# Install dependencies
RUN apt-get update -y &&\
	apt-get upgrade -y &&\
	apt-get update -y &&\
	apt-get install -y dos2unix

ADD ./install/requirements.txt ${INSTALL_DIR}/requirements.txt
RUN pip install -r ${INSTALL_DIR}/requirements.txt

# Add source
COPY ${DJANGO_PROJECT_NAME} ${WEB_ROOT}
WORKDIR ${WEB_ROOT}


# Entrypoint
COPY docker/entrypoint.sh ${DOCKER_DIR}/entrypoint.sh
RUN chmod -R 700 ${DOCKER_DIR} &&\
	dos2unix ${DOCKER_DIR}/*


ENTRYPOINT ${DOCKER_DIR}/entrypoint.sh