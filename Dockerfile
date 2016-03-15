# our base image, for now, Ubuntu
FROM ubuntu:14.04

# we will install packages here, the -y is imperative
RUN apt-get update -qq && apt-get install -y build-essential
#once we are done with the install, we clean it all up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#setup our working directory for the project, since this is a container, we can work out of a root directory
RUN mkdir /cvast_arches
WORKDIR /cvast_arches
