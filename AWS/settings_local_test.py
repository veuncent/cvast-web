from arches.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis', 
        'NAME': 'arches',   
        'USER': 'postgres',   
        'PASSWORD': 'postgis',
        'HOST': 'cvast-arches-db-loadb-test-2101097501.us-east-1.elb.amazonaws.com',
        'PORT': '5432',                      
        'SCHEMAS': 'public,data,ontology,concepts',
        'POSTGIS_TEMPLATE': 'template_postgis_20',
    }
}

ELASTICSEARCH_HOSTS = [
    {'host': 'cvast-arches-elastics-loadb-test-1322734012.us-east-1.elb.amazonaws.com', 'port': ELASTICSEARCH_HTTP_PORT}
	]