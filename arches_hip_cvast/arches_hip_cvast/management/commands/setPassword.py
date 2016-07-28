import os
import sys
from django.core.management.base import BaseCommand, CommandError
from django.contrib.auth.models import User

def get_env_variable(var_name):
    msg = "!!! ERROR! Please specify the %s environment variable. Exiting... !!!"
    try:
        return os.environ[var_name]
    except KeyError:
        error_msg = msg % var_name
        raise CommandError(error_msg)

class Command(BaseCommand):
    help = 'Sets the admin password based on the DJANGO_PASSWORD environment variable'

    def handle(self, *args, **options):
        self.stdout.write('Setting Django password for user admin.')
        user = User.objects.get(username='admin')
        password = get_env_variable('DJANGO_PASSWORD')
        user.set_password(password)
        user.save()
        self.stdout.write('Admin password set.')
