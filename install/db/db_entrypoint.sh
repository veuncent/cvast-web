#!/bin/bash
createdb -E UTF8 -T template0 --locale=en_US.utf8 template_postgis_20
psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis_20'"
psql -d template_postgis_20 -c "CREATE EXTENSION postgis;"
psql -d template_postgis_20 -c "GRANT ALL ON geometry_columns TO PUBLIC;"
psql -d template_postgis_20 -c "GRANT ALL ON geography_columns TO PUBLIC;"
psql -d template_postgis_20 -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"