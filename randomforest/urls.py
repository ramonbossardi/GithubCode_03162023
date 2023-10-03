# your_project_name/urls.py
from django.urls import path
from .views import *

urlpatterns = [
    
    path('', home_page, name='home_page'),
    path('upload/', upload_files_view, name='upload_files'),
    path('clear/', clear_files, name='clear_files'),
    path('analysis/<int:analysisId>/', individual_analysis, name='individual_analysis'),
    path('custom_function/', custom_function, name='custom_function'),
    path('customds_function/', custom_function, name='custom_function'),
    # Other URL patterns for your project
]
