from django.core.management.base import BaseCommand
from django.contrib.auth.models import User

class Command(BaseCommand):
    help = 'Set a user as admin by email'

    def handle(self, *args, **kwargs):
        try:
            user = User.objects.get(email='admin@email.com')
            user.is_staff = True
            user.is_superuser = True
            user.save()
            self.stdout.write(self.style.SUCCESS(f'Successfully set {user.email} as admin'))
        except User.DoesNotExist:
            self.stdout.write(self.style.ERROR('User with email admin@email.com not found'))
