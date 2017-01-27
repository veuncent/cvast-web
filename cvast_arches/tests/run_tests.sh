#!/bin/bash

script_dir=`dirname $0`

# Set Postgresql password in environment variable for authentication during tests
export PGPASSWORD=${PG_PASSWORD}

echo "."
echo "."
echo ----- RUNNING CORE ARCHES TESTS -----
echo "."
python ${script_dir}/../manage.py test tests --pattern="*_test.py" --verbosity=3

