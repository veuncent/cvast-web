# our base image, for now, Ubuntu
FROM ubuntu:14.04
#USER root

# Replace default command interpreter from sh to bash (needed for 'source' command)
# RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libxml2-dev libjson0-dev libproj-dev xsltproc docbook-xsl docbook-mathml libgdal1-dev openjdk-7-jdk python-setuptools python-dev libffi-dev libpq-dev postgresql-client-9.3 wget

# Add arches source code to image file system
WORKDIR /arches
COPY ./arches ./
COPY virtualenv-run-server.sh /arches
RUN chmod +x virtualenv-run-server.sh

RUN easy_install pip
RUN pip install virtualenv==1.11.4
RUN virtualenv ENV
RUN . ENV/bin/activate; \
	pip install pyopenssl ndg-httpsclient pyasn1 requests psycopg2 django_nose; \
	pip install -r arches/install/requirements.txt

RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/*

EXPOSE 8000

CMD [".", "ENV/bin/activate;", "python", "/arches/manage.py", "runserver", "0.0.0.0:8000"]
