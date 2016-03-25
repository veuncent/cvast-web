# our base image, for now, Ubuntu
FROM ubuntu:14.04
USER root
# Replace default command interpreter from sh to bash (needed for 'source' command)
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update -y 
RUN apt-get install -y build-essential
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libjson0-dev
RUN apt-get install -y libproj-dev
RUN apt-get install -y xsltproc docbook-xsl
RUN apt-get install -y docbook-mathml
RUN apt-get install -y libgdal1-dev
RUN apt-get install -y openjdk-7-jdk
RUN apt-get install -y python-setuptools
RUN apt-get install -y python-dev
RUN apt-get install -y libffi-dev
RUN apt-get install -y libpq-dev
# RUN apt-get install -y postgresql-9.3
# RUN apt-get install -y postgresql-contrib-9.3
RUN apt-get install -y postgresql-client-9.3
RUN apt-get install -y wget

# Install the Arches application
# Add arches source code to image file system
COPY arches /arches
# Create virtual environment
RUN	easy_install pip
WORKDIR /arches/virtualenv
RUN python virtualenv.py ENV &&\
	source /arches/virtualenv/ENV/bin/activate &&\
	pip install pyopenssl ndg-httpsclient pyasn1 requests psycopg2 django_nose &&\
	pip install -r /arches/arches/install/requirements.txt &&\
	# apt-get install -y wget &&\
	mkdir /arches/virtualenv/ENV/tmp &&\
	cd /arches/virtualenv/ENV/tmp &&\
	wget http://download.osgeo.org/geos/geos-3.4.2.tar.bz2 &&\
	tar xvfj geos-3.4.2.tar.bz2 &&\
	cd geos-3.4.2 &&\
	./configure &&\
	make &&\
	make install &&\
	cd /arches &&\
	pip install arches
	# python setup.py build &&\
	# python setup.py install
	# pip install virtualenv==1.11.4 &&\
	# cd /arches &&\
	# virtualenv ENV &&\
	# source /arches/ENV/bin/activate &&\
# RUN pip install pyopenssl ndg-httpsclient pyasn1 requests psycopg2 django_nose
# RUN	pip install -r /arches/arches/install/requirements.txt

	# cd /arches &&\
# RUN	python manage.py packages -o install

# RUN pip install django --upgrade
# RUN pip install pyopenssl ndg-httpsclient pyasn1 requests psycopg2 django_nose
# Install the Arches application
	# cd /arches &&\ 
	# python manage.py packages -o install
	# python setup.py build &&\
	# python setup.py install
	# pip install -e ./

# user root
# WORKDIR /tmp
# RUN wget http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
# RUN tar xvfj geos-3.4.2.tar.bz2
# WORKDIR /tmp/geos-3.4.2
# RUN ./configure
# RUN make
# RUN make install


# WORKDIR /arches
# RUN python manage.py packages -o install
# RUN python manage.py packages -o migrate

# RUN pip install -e ./

	# cd /arches &&\
# RUN ./buildAndInstall.sh
# RUN python setup.py build
# RUN python setup.py install


# Cleanup
USER root
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/*

EXPOSE 8000

CMD ["source /arches/virtualenv/ENV/bin/activate && python /arches/manage.py runserver 0.0.0.0:8000"]
