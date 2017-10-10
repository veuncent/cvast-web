#!/usr/bin/env python
import os
import sys
import ptvsd
from cvast_web import settings

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "cvast_web.settings")
    try:
        from django.core.management import execute_from_command_line
    except ImportError:
        # The above import may fail for some other reason. Ensure that the
        # issue is really that Django is missing to avoid masking other
        # exceptions on Python 2.
        try:
            import django
        except ImportError:
            raise ImportError(
                "Couldn't import Django. Are you sure it's installed and "
                "available on your PYTHONPATH environment variable? Did you "
                "forget to activate a virtual environment?"
            )
        raise

    if settings.REMOTE_DEBUG:
        if not ptvsd.is_attached:
            debug_secret = settings.get_optional_env_variable("DEBUG_SECRET")
            ptvsd.enable_attach(debug_secret, address =('0.0.0.0', 3000))
            if ptvsd.is_attached:
                print "Attached debugger"
            else:
                print "Not attached"


    execute_from_command_line(sys.argv)

