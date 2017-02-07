#!/bin/bash
python manage.py packages -o install
python manage.py packages -o load_concept_scheme -s cvast_arches/source_data/concepts/authority_files