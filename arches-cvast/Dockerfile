# our base image, for now, Ubuntu
FROM ubuntu:14.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update -qq && apt-get install -y build-essential libxml2-dev libjson0-dev libproj-dev xsltproc docbook-xsl docbook-mathml libgdal1-dev openjdk-7-jdk python-setuptools python-dev


# Create virtual environment
WORKDIR /arches
RUN easy_install pip
RUN pip install virtualenv==1.11.4
RUN virtualenv ENV
RUN source ENV/bin/activate
RUN pip install arches

EXPOSE 8000

# CMD ["/usr/bin/supervisord"]
