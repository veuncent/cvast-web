# our base image, for now, Ubuntu
FROM ubuntu:14.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Setting locale variables for database
RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_LANG en_US.UTF-8
ENV LC_LANGUAGE en_US.UTF-8

USER root
COPY ./Resources/ubuntu_trusty_setup.sh /Resources/ubuntu_trusty_setup.sh
WORKDIR /Resources
RUN chmod +755 ./ubuntu_trusty_setup.sh
RUN ./ubuntu_trusty_setup.sh

#once we are done with the install, we clean it all up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#setup our working directory for the project, since this is a container, we can work out of a root directory
# RUN mkdir /cvast_arches
# WORKDIR /cvast_arches
