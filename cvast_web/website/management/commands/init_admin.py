from django.conf import settings
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User

class Command(BaseCommand):

    def handle(self, *args, **options):
        username = 'admin'
        email = 'admin@example.com'
        password = 'admin'
        admin = User.objects.create_superuser(username=username, email=email, password=password)
        admin.is_active = True
        admin.save()
