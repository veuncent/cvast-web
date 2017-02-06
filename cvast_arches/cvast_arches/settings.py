import os
import inspect
from arches_hip.settings import *
from django.utils.translation import ugettext as _
from django.core.exceptions import ImproperlyConfigured
import ast
import requests

def get_env_variable(var_name):
    msg = "Set the %s environment variable"
    try:
        return os.environ[var_name]
    except KeyError:
        error_msg = msg % var_name
        raise ImproperlyConfigured(error_msg)

MODE = get_env_variable('DJANGO_MODE') #options are either "PROD" or "DEV" (installing with Dev mode set, get's you extra dependencies)
DEBUG = ast.literal_eval(get_env_variable('DJANGO_DEBUG'))
TEMPLATE_DEBUG = DEBUG
ALLOWED_HOSTS = get_env_variable('DOMAIN_NAMES').split()

# Fix for AWS ELB returning false bad health: ALLOWS_HOSTS did not allow ELB's private ip
EC2_PRIVATE_IP = None
try:
    EC2_PRIVATE_IP = requests.get('http://169.254.169.254/latest/meta-data/local-ipv4', timeout=0.01).text
except requests.exceptions.RequestException:
    pass
if EC2_PRIVATE_IP:
    ALLOWED_HOSTS.append(EC2_PRIVATE_IP)
EC2_PUBLIC_HOSTNAME = None
try:
    EC2_PUBLIC_HOSTNAME = requests.get('http://169.254.169.254/latest/meta-data/public-hostname', timeout=0.01).text
except requests.exceptions.RequestException:
    pass
if EC2_PUBLIC_HOSTNAME:
    ALLOWED_HOSTS.append(EC2_PUBLIC_HOSTNAME)

STATIC_ROOT = '/static_root'

PACKAGE_ROOT = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
PACKAGE_NAME = PACKAGE_ROOT.split(os.sep)[-1]
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

ELASTICSEARCH_HOSTS = [
    {'host': get_env_variable('ES_HOST'), 'port': ELASTICSEARCH_HTTP_PORT}

]

ROOT_URLCONF = '%s.urls' % (PACKAGE_NAME)
INSTALLED_APPS = INSTALLED_APPS + (PACKAGE_NAME,)
STATICFILES_DIRS = (
        os.path.join(PACKAGE_ROOT, 'media'),
        os.path.join(PACKAGE_ROOT, '..', '..', 'arches_hip', 'arches_hip', 'media'), # Added by Vincent: cvast_arches needed this, but couldn't find it
) + STATICFILES_DIRS
TEMPLATE_DIRS = (
        os.path.join(PACKAGE_ROOT, 'templates'),
        os.path.join(PACKAGE_ROOT, 'templatetags'),
        os.path.join(PACKAGE_ROOT, '..', '..', 'arches_hip', 'arches_hip', 'templates'), # Added by Vincent: cvast_arches needed this, but couldn't find it
    ) + TEMPLATE_DIRS
RESOURCE_MODEL = {'default': 'arches_hip.models.resource.Resource'}
APP_NAME = 'USF CVAST'
PACKAGE_VALIDATOR = 'cvast_arches.source_data.validation.HIP_Validator'

DEFAULT_MAP_X = -224149.03751366
DEFAULT_MAP_Y = 6978966.6705368
DEFAULT_MAP_ZOOM = 3
MAP_MIN_ZOOM = 0
MAP_MAX_ZOOM = 19
MAP_LAYER_FEATURE_LIMIT = 100000
MAP_EXTENT = ''

def RESOURCE_TYPE_CONFIGS():
    return {
        'HERITAGE_RESOURCE.E18': {
            'resourcetypeid': 'HERITAGE_RESOURCE.E18',
            'name': _('Historic Resource'),
            'icon_class': 'fa fa-university',
            'default_page': 'summary',
            'default_description': 'No description available',
            'description_node': _('DESCRIPTION.E62'),
            'categories': [_('Resource')],
            'has_layer': True,
            'on_map': False,
            'marker_color': '#fa6003',
            'stroke_color': '#fb8c49',
            'fill_color': '#ffc29e',
            'primary_name_lookup': {
                'entity_type': 'NAME.E41',
                'lookup_value': 'Primary'
            },
            'sort_order': 1
        },
        'HERITAGE_RESOURCE_GROUP.E27': {
            'resourcetypeid': 'HERITAGE_RESOURCE_GROUP.E27',
            'name': _('Historic District'),
            'icon_class': 'fa fa-th',
            'default_page': 'summary',
            'default_description': 'No description available',
            'description_node': _('REASONS.E62'),
            'categories': [_('Resource')],
            'has_layer': True,
            'on_map': False,
            'marker_color': '#FFC53D',
            'stroke_color': '#d9b562',
            'fill_color': '#eedbad',
            'primary_name_lookup': {
                'entity_type': 'NAME.E41',
                'lookup_value': 'Primary'
            },
            'sort_order': 2
        },
        'ACTIVITY.E7': {
            'resourcetypeid': 'ACTIVITY.E7',
            'name': _('Activity'),
            'icon_class': 'fa fa-tasks',
            'default_page': 'activity-summary',
            'default_description': 'No description available',
            'description_node': _('INSERT RESOURCE DESCRIPTION NODE HERE'),
            'categories': [_('Resource')],
            'has_layer': True,
            'on_map': False,
            'marker_color': '#6DC3FC',
            'stroke_color': '#88bde0',
            'fill_color': '#afcce1',
            'primary_name_lookup': {
                'entity_type': 'NAME.E41',
                'lookup_value': 'Primary'
            },
            'sort_order': 3
        },
        'HISTORICAL_EVENT.E5':{
            'resourcetypeid': 'HISTORICAL_EVENT.E5',
            'name': _('Historic Event'),
            'icon_class': 'fa fa-calendar',
            'default_page': 'historical-event-summary',
            'default_description': 'No description available',
            'description_node': _('INSERT RESOURCE DESCRIPTION NODE HERE'),
            'categories': [_('Resource')],
            'has_layer': True,
            'on_map': False,
            'marker_color': '#4EBF41',
            'stroke_color': '#61a659',
            'fill_color': '#c2d8bf',
            'primary_name_lookup': {
                'entity_type': 'NAME.E41',
                'lookup_value': 'Primary'
            },
            'sort_order': 4
        },
        'ACTOR.E39': {
            'resourcetypeid': 'ACTOR.E39',
            'name': _('Person/Organization'),
            'icon_class': 'fa fa-group',
            'default_page': 'actor-summary',
            'default_description': 'No description available',
            'description_node': _('INSERT RESOURCE DESCRIPTION NODE HERE'),
            'categories': [_('Resource')],
            'has_layer': True,
            'on_map': False,
            'marker_color': '#a44b0f',
            'stroke_color': '#a7673d',
            'fill_color': '#c8b2a3',
            'primary_name_lookup': {
                'entity_type': 'ACTOR_APPELLATION.E82',
                'lookup_value': 'Primary'
            },
            'sort_order': 5
        },
        'INFORMATION_RESOURCE.E73': {
            'resourcetypeid': 'INFORMATION_RESOURCE.E73',
            'name': _('Information Resource'),
            'icon_class': 'fa fa-file-text-o',
            'default_page': 'information-resource-summary',
            'default_description': 'No description available',
            'description_node': _('INSERT RESOURCE DESCRIPTION NODE HERE'),
            'categories': [_('Resource')],
            'has_layer': True,
            'on_map': False,
            'marker_color': '#8D45F8',
            'stroke_color': '#9367d5',
            'fill_color': '#c3b5d8',
            'primary_name_lookup': {
                'entity_type': 'TITLE.E41',
                'lookup_value': 'Primary'
            },
            'sort_order': 6
        }
    }

ELASTICSEARCH_CONNECTION_OPTIONS = {'timeout': 600}

EXPORT_CONFIG = ''

DATE_SEARCH_ENTITY_TYPES = ['BEGINNING_OF_EXISTENCE_TYPE.E55', 'END_OF_EXISTENCE_TYPE.E55']

RESOURCE_GRAPH_LOCATIONS = (
    # Put strings here, like "/home/data/resource_graphs" or "C:/data/resource_graphs".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    os.path.join(PACKAGE_ROOT, 'source_data', 'resource_graphs'),
)
CONCEPT_SCHEME_LOCATIONS = (
    # Put strings here, like "/home/data/authority_files" or "C:/data/authority_files".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.

    # 'absolute/path/to/authority_files',
    # os.path.join(PACKAGE_ROOT, 'source_data', 'sample_data', 'concepts', 'sample_authority_files'),
)
BUSISNESS_DATA_FILES = (
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

### Media

S3_STATIC_URL = 'https://media.usfcvast.org'
S3_STATIC_URL_IMG = os.path.join(S3_STATIC_URL, 'images', 'cvast-arches')
S3_STATIC_URL_VIDEO = os.path.join(S3_STATIC_URL, 'videos', 'cvast-arches')

# Absolute filesystem path to the directory that will hold user-uploaded files.
MEDIA_ROOT =  os.path.join(PACKAGE_ROOT, 'uploadedfiles')

# URL that handles the media served from MEDIA_ROOT, used for managing stored files.
# It must end in a slash if set to a non-empty value.
MEDIA_URL = '/files/'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': os.path.join(PACKAGE_ROOT, 'logs', 'application.txt'),
        },
    },
    'loggers': {
        'arches': {
            'handlers': ['file'],
            'level': 'DEBUG',
            'propagate': True,
        },
        'arches_hip': {
            'handlers': ['file'],
            'level': 'DEBUG',
            'propagate': True,
        }
    },
}


DATE_PARSING_FORMAT = ['%B %d, %Y', '%Y-%m-%d', '%Y-%m-%d %H:%M:%S']

TEMPLATE_CONTEXT_PROCESSORS = (
    'cvast_arches.utils.context_processors.media_settings',
) + TEMPLATE_CONTEXT_PROCESSORS

try:
    from settings_local import *
except ImportError:
    pass
