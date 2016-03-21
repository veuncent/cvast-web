# our base image, for now, Ubuntu
FROM ubuntu:14.04

# Replace default command interpreter from sh to bash (needed for 'source' command)
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libxml2-dev libjson0-dev libproj-dev xsltproc docbook-xsl docbook-mathml libgdal1-dev openjdk-7-jdk python-setuptools python-dev libffi-dev libpq-dev

# Add arches source code to image file system
COPY arches /arches

# Create virtual environment
WORKDIR /arches
RUN easy_install pip
RUN pip install virtualenv==1.11.4
RUN virtualenv ENV
RUN source ENV/bin/activate

# Install the Arches application
RUN pip install pyopenssl ndg-httpsclient pyasn1 requests psycopg2 django_nose
RUN pip install -r arches/install/requirements.txt

EXPOSE 8000
