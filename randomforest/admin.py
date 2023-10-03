from django.contrib import admin
from .models import *
# Register your models here.

admin.site.register(UploadedFolder)
admin.site.register(CellLines)
admin.site.register(LastTrainingResultsRandomForest)
admin.site.register(LastTrainingResultsKFDA)
admin.site.register(AnalysisRun)