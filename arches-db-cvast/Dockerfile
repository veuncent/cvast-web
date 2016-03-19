# our base image, for now, Ubuntu
FROM ubuntu:14.04

USER root
RUN apt-get update -y
RUN apt-get install -y make python-software-properties
# Fix error: add-apt-repository: command not found
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

USER postgres
RUN psql -d postgres -c "ALTER USER postgres with encrypted password 'postgis';"

USER root
RUN echo "*:*:*:postgres:postgis" >> ~/.pgpass
RUN chmod 600 ~/.pgpass
RUN chmod 666 /etc/postgresql/9.3/main/postgresql.conf
RUN chmod 666 /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "standard_conforming_strings = off" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "#TYPE   DATABASE  USER  CIDR-ADDRESS  METHOD" > /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "local   all       all                 trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host    all       all   127.0.0.1/32  trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host    all       all   ::1/128       trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host    all       all   0.0.0.0/0     md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN service postgresql restart -p 5433

RUN wget http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
RUN tar xvfj geos-3.4.2.tar.bz2

WORKDIR geos-3.4.2
./configure
RUN make
RUN make install

WORKDIR ..
RUN wget http://download.osgeo.org/postgis/source/postgis-2.1.3.tar.gz
RUN tar xfvz postgis-2.1.3.tar.gz

WORKDIR postgis-2.1.3
./configure
RUN make
RUN make install
RUN ldconfig
RUN make comments-install
RUN ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/shp2pgsql
RUN ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/pgsql2shp
RUN ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/raster2pgsql

WORKDIR ..
USER postgres
RUN  psql -d postgres -c "CREATE EXTENSION postgis;"
RUN createdb -E UTF8 -T template0 --locale=en_US.utf8 template_postgis_20
RUN createlang -d template_postgis_20 plpgsql
RUN psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis_20'"
RUN psql -d template_postgis_20 -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql
RUN psql -d template_postgis_20 -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql
RUN psql -d template_postgis_20 -f /usr/share/postgresql/9.3/contrib/postgis-2.1/rtpostgis.sql
RUN psql -d template_postgis_20 -c "GRANT ALL ON geometry_columns TO PUBLIC;"
RUN psql -d template_postgis_20 -c "GRANT ALL ON geography_columns TO PUBLIC;"
RUN psql -d template_postgis_20 -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

USER root
RUN createdb training -T template_postgis_20

RUN apt-get install -y openjdk-7-jdk python-setuptools python-dev

USER postgres
RUN createdb -E UTF8 -T template_postgis_20 --locale=en_US.utf8 arches

USER root
#once we are done with the install, we clean it all up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#setup our working directory for the project, since this is a container, we can work out of a root directory
# RUN mkdir /cvast_arches
# WORKDIR /cvast_arches
