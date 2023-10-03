from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timedelta
from pytz import timezone
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from randomforest.importdata import parameter_import

def schedules():
    print('Scheduler is running...')
    scheduler = BackgroundScheduler(timezone='UTC')
    jobfunction = parameter_import

    # Get the current time in your timezone
    current_time = datetime.now(scheduler.timezone)

    # Calculate the next minute ending with 0
    next_minute_ending_with_0 = current_time + timedelta(minutes=(10 - current_time.minute % 10))

    # Set the job to start at the next minute ending with 0
    trigger = CronTrigger(
        minute=next_minute_ending_with_0.minute,
        hour=next_minute_ending_with_0.hour
    )
    scheduler.add_job(jobfunction,"interval", minutes = 5, id="events", replace_existing=True)

    scheduler.start()

# def happyhourscheduler():
#       print('Scheduler is runningd  trararara...')
#       scheduler = BackgroundScheduler()
#       happyhour = ActivatingDeactivatingHappyHour()
#       scheduler.add_job(happyhour.sethappyhour, "interval", minutes=1,id="happyhour_001",replace_existing=True)
#       scheduler.start()
      
      

def Acting():
      print("yes")