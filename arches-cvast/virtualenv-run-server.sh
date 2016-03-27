#!/usr/bin/env bash
cd /arches
source ENV/bin/activate
python manage.py runserver 0.0.0.0:8000
