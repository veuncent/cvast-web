import posixpath
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "arches_hip.settings")
from os import listdir
from os.path import isfile, join
import glob
import codecs
import traceback
from arches.management.commands.package_utils import resource_graphs
import arches.app.utils.data_management.resources.remover as resource_remover
from arches.management.commands import utils
from django.core import management
# os.environ.setdefault("DJANGO_SETTINGS_MODULE", "arches.settings")

from arches.arches_hip.arches_hip import setup
from arches.app.models.resource import Resource

def install_arches_hip(path_to_source_data_dir=None):
    print "truncate_db"
    setup.truncate_db()
    # Resource().prepare_term_index(create=True)
    print "load_graphs"
    load_graphs()
    print "load_authority_files"
    setup.load_authority_files(path_to_source_data_dir)
    print "load_map_layers"    
    setup.load_map_layers()

    # setup.create_indexes()
    resource_remover.truncate_resources()
    print "load_resources"
    setup.load_resources()


# Custom load_graphs function that ommits everything not database related (e.g. elastic search parts)
def load_graphs(break_on_error=True, settings=None):
    """
    Iterates through the resource node and edge files to load entitytypes and mappings into the database.
    Generates node level permissions for each resourcetype/entitytype combination

    """

    if not settings:
        from django.conf import settings        
  
    suffix = '_nodes.csv'
    errors = []
    #file_list = []

    for path in settings.RESOURCE_GRAPH_LOCATIONS:
        if os.path.exists(path):
            print '\nLOADING GRAPHS (%s)' % (path)
            print '---------------'
            for f in listdir(path):
                if isfile(join(path,f)) and f.endswith(suffix):
                    #file_list.append(join(path,f))
                    path_to_file = join(path,f)
                    basepath = path_to_file[:-10]
                    name = basepath.split(os.sep)[-1]
                    if (settings.LIMIT_ENTITY_TYPES_TO_LOAD == None or name in settings.LIMIT_ENTITY_TYPES_TO_LOAD):
                        print name
                        node_list = resource_graphs.get_list_dict(basepath + '_nodes.csv', ['ID', 'LABEL', 'MERGENODE', 'BUSINESSTABLE'])
                        edge_list = resource_graphs.get_list_dict(basepath + '_edges.csv', ['SOURCE', 'TARGET', 'TYPE', 'ID', 'LABEL', 'WEIGHT'])
                        mods = resource_graphs.append_branch(os.path.join(settings.ROOT_DIR, 'management', 'resource_graphs', 'ARCHES_RECORD.E31'), node_list, edge_list)
                        node_list = mods['node_list']
                        edge_list = mods['edge_list']

                        file_errors = resource_graphs.validate_graph(node_list, edge_list)
                        try:
                            resource_graphs.insert_mappings(node_list, edge_list)
                            resource_graphs.link_entitytypes_to_concepts(node_list)
                        except Exception as e:
                            file_errors.append('\nERROR: %s\n%s' % (str(e), traceback.format_exc()))
                            pass

                        if len(file_errors) > 0:
                            file_errors.insert(0, 'ERRORS IN FILE: %s\n' % (basepath))
                            file_errors.append('\n\n\n\n')
                            errors = errors + file_errors  
        else:
            errors.append('\n\nPath in settings.RESOURCE_GRAPH_LOCATIONS doesn\'t exist (%s)' % (path))                 

    utils.write_to_file(os.path.join(settings.PACKAGE_ROOT, 'logs', 'resource_graph_errors.txt'), '')
    if len(errors) > 0:
        utils.write_to_file(os.path.join(settings.PACKAGE_ROOT, 'logs', 'resource_graph_errors.txt'), '\n'.join(errors))
        print "\n\nERROR: There were errors in some of the resource graphs."
        print "Please review the errors at %s, \ncorrect the errors and then rerun this script." % (os.path.join(settings.PACKAGE_ROOT, 'logs', 'resource_graph_errors.txt'))
        if break_on_error:
            sys.exit(101)

    print '\nADDING NODE LEVEL PERMISSIONS'
    print '-----------------------------'
    management.call_command('packages', operation='build_permissions') 


if __name__ == "__main__":
    install_arches_hip()
