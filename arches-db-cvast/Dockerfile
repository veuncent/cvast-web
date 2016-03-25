# our base image, for now, Ubuntu
FROM ubuntu:14.04

USER root
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Setting locale variables for database


RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_LANG en_US.UTF-8
ENV LC_LANGUAGE en_US.UTF-8

#!/usr/bin/env bash
RUN apt-get update -y
RUN apt-get install -y make python-software-properties
# Fix error in ubuntu_trusty_setup.sh: add-apt-repository: command not found
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
RUN apt-get update -y

RUN apt-get install -y build-essential
RUN apt-get install -y postgresql-9.3
RUN apt-get install -y postgresql-server-dev-9.3
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libproj-dev
RUN apt-get install -y libjson0-dev
RUN apt-get install -y xsltproc
RUN apt-get install -y docbook-xsl
RUN apt-get install -y docbook-mathml
RUN apt-get install -y libgdal1-dev
RUN apt-get install -y postgresql-contrib-9.3
RUN apt-get install -y postgresql-server-dev-9.3
RUN apt-get install -y libpq-dev
RUN apt-get install -y wget
RUN apt-get install -y openjdk-7-jdk  
RUN apt-get install -y python-setuptools
RUN apt-get install -y python-dev

USER postgres
RUN /etc/init.d/postgresql start &&\
	psql -d postgres -c "CREATE USER docker with encrypted password 'docker';" &&\
	psql -d postgres -c "ALTER USER postgres with encrypted password 'postgres';"

USER root
RUN echo "*:*:*:postgres:postgis" >> ~/.pgpass
RUN echo "*:*:*:docker:docker" >> ~/.pgpass
RUN chmod 600 ~/.pgpass
RUN chmod 666 /etc/postgresql/9.3/main/postgresql.conf
RUN chmod 666 /etc/postgresql/9.3/main/pg_hba.conf

# USER postgres
RUN echo "standard_conforming_strings = off" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "#TYPE   DATABASE  USER  CIDR-ADDRESS  METHOD" > /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "local   all       all                 trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host    all       all   127.0.0.1/32  trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host    all       all   ::1/128       trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host    all       all   0.0.0.0/0     md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host all all 127.0.0.1 255.255.255.0 trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN service postgresql restart

# user root
WORKDIR /tmp
RUN wget http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
RUN tar xvfj geos-3.4.2.tar.bz2
WORKDIR /tmp/geos-3.4.2
RUN ./configure
RUN make
RUN make install

WORKDIR /tmp
RUN wget http://download.osgeo.org/postgis/source/postgis-2.1.3.tar.gz
RUN tar xfvz postgis-2.1.3.tar.gz
WORKDIR /tmp/postgis-2.1.3
RUN ./configure
RUN make
RUN make install
RUN ldconfig
RUN make comments-install
RUN ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/shp2pgsql
RUN ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/pgsql2shp
RUN ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/raster2pgsql

user postgres
WORKDIR /
RUN /etc/init.d/postgresql start &&\
	psql -d postgres -c "CREATE EXTENSION postgis;" &&\
	createdb -E UTF8 -T template0 --locale=en_US.utf8 template_postgis_20 &&\
	# createlang -d template_postgis_20 plpgsql &&\
	psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis_20'" &&\
	psql -d template_postgis_20 -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql &&\
	psql -d template_postgis_20 -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql &&\
	psql -d template_postgis_20 -f /usr/share/postgresql/9.3/contrib/postgis-2.1/rtpostgis.sql &&\
	psql -d template_postgis_20 -c "GRANT ALL ON geometry_columns TO PUBLIC;" &&\
	psql -d template_postgis_20 -c "GRANT ALL ON geography_columns TO PUBLIC;" &&\
	psql -d template_postgis_20 -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;" &&\
	createdb training -T template_postgis_20 &&\

# RUN /etc/init.d/postgresql start &&\
	createdb -E UTF8 -T template_postgis_20 --locale=en_US.utf8 arches

# Cleanup
USER root
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/*

# RUN service postgresql restart

# USER postgres
EXPOSE 5432
VOLUME ["/var/lib/postgresql", "/home/setup"]
# CMD /etc/init.d/postgresql start
CMD service postgresql start 
# CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]




