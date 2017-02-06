#!/bin/bash

script_dir=`dirname $0`

echo "."
echo "."
echo ----- RUNNING CORE ARCHES TESTS -----
echo "."
python ${script_dir}/../manage.py test tests --pattern="*_test.py" --verbosity=3

