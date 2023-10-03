# celery.py
from __future__ import absolute_import, unicode_literals
import os
from celery import Celery

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'OTCCPScript.settings')

app = Celery('OTCCPScript',broker = 'redis://default:GhzwMeEhDjJqqLN2k3ONOwaS9z1nXy4J@redis-12414.c10.us-east-1-2.ec2.cloud.redislabs.com:12414')

# Load task modules from all registered Django app configs.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Auto-discover tasks in all installed apps
app.autodiscover_tasks()
