import os
import django
from django.core.management import execute_from_command_line

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

def run_migrations():
	# Make migrations
	execute_from_command_line(['manage.py', 'makemigrations', 'food'])
	# Apply migrations
	execute_from_command_line(['manage.py', 'migrate'])

if __name__ == '__main__':
	run_migrations()