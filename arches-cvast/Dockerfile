# our base image, for now, Ubuntu
FROM ubuntu:14.04
# Replace default command interpreter from sh to bash (needed for 'source' command)
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Add arches source code to image file system
ADD /arches /arches

## Installing dependencies and database
USER root

# Setting locale variables for database
RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_LANG en_US.UTF-8
ENV LC_LANGUAGE en_US.UTF-8

# Fix error in ubuntu_trusty_setup.sh: add-apt-repository: command not found
# RUN  apt-get update -y
# RUN apt-get install software-properties-common

# Install dependencies
WORKDIR /arches/arches/install
RUN ./ubuntu_trusty_setup.sh

# Create virtual environment 
WORKDIR /arches
RUN python virtualenv/virtualenv.py ENV
RUN source ENV/bin/activate

# Install the Arches application
# Reminder: settings.py is set to DEV: extra dependencies
RUN python setup.py build
RUN python setup.py install

# WORKDIR /arches/arches
# RUN python3 ./setup.py



##once we are done with the install, we clean it all up
# RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# WORKDIR /arches/tests
# RUN ./run_tests.py


# WORKDIR /

# RUN mkdir -p /var/run/sshd
# RUN mkdir -p /var/log/supervisor

# RUN echo 'root:root' |chpasswd

# ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 8000

# CMD ["/usr/bin/supervisord"]

#setup our working directory for the project, since this is a container, we can work out of a root directory
# RUN mkdir /cvast_arches
# WORKDIR /cvast_arches
