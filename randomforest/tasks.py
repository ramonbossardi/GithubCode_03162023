# tasks.py in your app
from celery import shared_task

@shared_task
def process_analysis_run(analysis_run_id):
    print("runnings")
    pass
