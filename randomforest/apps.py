from django.apps import AppConfig


class RandomforestConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'randomforest'

    
    # def ready(self):
    #     print('Scheduler is starting...')
    #     from .scheduler import scheduler
        
    #     scheduler.schedules()