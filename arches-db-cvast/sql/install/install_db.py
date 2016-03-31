# import inspect
import posixpath
import os
import glob
import codecs


# from django.template import Template
# from django.conf import settings
# from django.template import Context
# from arches.management.commands import utils

def run_initial_sql():
    here = os.path.dirname(os.path.abspath(__file__))
    db_directory = os.path.abspath(os.path.join(here, '..'))
    path_to_file = os.path.join(db_directory, 'install_db.sql')

    # Generate a sql file that sources all necessary sql files into one file
    buffer = ''
    buffer += "\n-- Run all the sql scripts in the dependencies folder\n"
    for infile in glob.glob(posixpath.join(db_directory, 'install', 'dependencies', '*.sql')):
        buffer += source(infile.replace("\\", posixpath.sep))

    buffer += "\n-- Reload all managed schemas\n"
    for infile in glob.glob(posixpath.join(db_directory, 'ddl', '*.sql')):
        buffer += source(infile.replace("\\", posixpath.sep))

    buffer += "\n-- Add all the data in the dml folder\n"
    for infile in glob.glob(posixpath.join(db_directory, 'dml', '*.sql')):
        buffer += source(infile.replace("\\", posixpath.sep))

    buffer += "\n-- Run all the sql in teh postdeployment folder\n"
    for infile in glob.glob(posixpath.join(db_directory, 'install', 'postdeployment', '*.sql')):
        buffer += source(infile.replace("\\", posixpath.sep))

    buffer += "\n-- Spring cleaning\n"
    buffer += "VACUUM ANALYZE;\n"

    write_to_file(path_to_file, buffer)
    # os.system('psql -d postgres -c %') % buffer

    os.system('psql -d arches -f %s' % path_to_file)


def write_to_file(fileName, contents, mode='w', encoding='utf-8', **kwargs):
    ensure_dir(fileName)
    file = codecs.open(fileName, mode=mode, encoding=encoding, **kwargs)
    file.write(contents)
    os.system('chmod -R 777 ' + fileName)
    file.close()


def ensure_dir(f):
    d = os.path.dirname(f)
    if not os.path.exists(d):
        os.makedirs(d)


def source(file):
    return "\i \'" + file + "\'\n"


if __name__ == "__main__":
    run_initial_sql()
