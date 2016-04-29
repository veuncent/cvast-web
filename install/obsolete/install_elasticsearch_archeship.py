import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "arches.settings")

from arches.management.commands.package_utils import concepts
from arches.arches_hip.arches_hip import setup
from arches.app.models.resource import Resource


def install_elasticsearch_archeship():

    setup.delete_index(index='concept_labels')
    setup.delete_index(index='term') 
    Resource().prepare_term_index(create=True)

    print '\nINDEXING ENTITY NODES'
    print '---------------------'
    concepts.index_entity_concept_lables()

    setup.delete_index(index='resource')
    setup.delete_index(index='entity')
    setup.delete_index(index='maplayers')
    setup.delete_index(index='resource_relations') 
    setup.create_indexes()  

if __name__ == "__main__":
    install_elasticsearch_archeship()