from settings import *
# import os
# from django.core.exceptions import ImproperlyConfigured

# def get_env_variable(var_name):
#     msg = "Set the %s environment variable"
#     try:
#         return os.environ[var_name]
#     except KeyError:
#         error_msg = msg % var_name
#         raise ImproperlyConfigured(error_msg)

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis', 
        'NAME': get_env_variable('PGDBNAME'),
        'USER': 'postgres',    
        'PASSWORD': get_env_variable('PGPASSWORD'), 
        'HOST': get_env_variable('PGHOST'),          
        'PORT': get_env_variable('PGPORT'),        
        'SCHEMAS': 'public,data,ontology,concepts',
        'POSTGIS_TEMPLATE': 'template_postgis_20',
    }
}