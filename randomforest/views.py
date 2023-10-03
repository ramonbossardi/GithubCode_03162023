# your_app_name/views.py
from daphne.server import twisted_loop
import os
import glob
import shutil
from django.conf import settings
from django.shortcuts import render
from django.http import HttpResponse
from randomforest.models import *
from .forms import OptionForm, UploadFolderForm
from .importdata import parameter_import, parameter_calc
import threading
import numpy as np
from randomforest.train import train



def home_page(request):
    data = AnalysisRun.objects.all()
    # lastRfTrainingModel = analysis.random_forest
    # lastkfdaTrainingModel = analysis.kfda

    return render(request, 'homepage.html', { 'data': data})

  



def individual_analysis(request,analysisId):
    analysis =AnalysisRun.objects.get(pk= analysisId)
    lastRfTrainingModel = analysis.random_forest
    lastkfdaTrainingModel = analysis.kfda

    return render(request, 'individual_analysis.html', {'randomForest': lastRfTrainingModel,'kfda': lastkfdaTrainingModel, "analysis":analysis})


def runanalysis():
    parameter_import

    

def clear_files(request):
    # if request.method == 'POST':
    files = UploadedFolder.objects.all()
    for file in files:
        file.delete()

    return HttpResponse("Successfully cleared! Navigate back!")



# @silk_profile
def upload_files_view(request):
    if request.method == 'POST':
        
        print("Check Uploads")
        # print(request.FILES)
        # print(request.FILES.getlist('folder'))

        print("Check Uploads")

        form = UploadFolderForm(request.POST, request.FILES)
        # form.save()
        if form.is_valid():
            # Create a temporary directory to store uploaded files
            temp_dir = os.path.join(settings.MEDIA_ROOT, 'temp_folder')
            os.makedirs(temp_dir, exist_ok=True)

            for file in request.FILES.getlist('folder'):
                uploadfile = UploadedFolder(
                    folder = file,
                    cellline =  form.cleaned_data["cellline"]
                )
              
                uploadfile.save()
                
                print("File '{}' copied successfully.".format(file.name))

            form = UploadFolderForm() 
                
            # [X_new, X_labels, objectID, cell_list] = parameter_import()
            # parameter_calc(X_new,objectID)

         

            # Clean up: remove temporary directory and files
            # shutil.rmtree(temp_dir)


        analysis_form = OptionForm(request.POST) 

        
        if analysis_form.is_valid():
            # Process the form data, e.g., save to the database
            # You can access the selected options using form.cleaned_data
            # For example:
            selected_cell_line_options = analysis_form.cleaned_data['cell_line_options']
            # selected_comp_options = analysis_form.cleaned_data['comp_options']
            # selected_comp_options_str = ','.join(selected_comp_options)
            # selected_param_options = analysis_form.cleaned_data['param_options']
            # selected_param_options_str = ','.join(selected_comp_options)


            analysis =  AnalysisRun(
                progress = 0.3,
                email = "dancan.oruko99@gmail.com"
                
            )
            analysis.save()

            timer = threading.Timer(3.0,parameter_import)
            timer.start()
            
            analysis = AnalysisRun.objects.last()
            for celline in selected_cell_line_options:
                print(celline)
                analysis.celllines.add(celline)
            
            analysis.save()

            analysis_form = OptionForm()
            
            # Perform your processing here

            # Redirect or render a success page
            # return redirect('success_page')

    else:
            
        #  
        
        form = UploadFolderForm()
        analysis_form = OptionForm()
    
    analysis = AnalysisRun.objects.last()
    lastRfTrainingModel =  LastTrainingResultsRandomForest.objects.last()
    lastkfdaTrainingModel =  LastTrainingResultsKFDA.objects.last()

    return render(request, 'dataupload.html', {'form': form,'randomForest': lastRfTrainingModel,'kfda': lastkfdaTrainingModel,  'analysis_form':analysis_form,"analysis":analysis})




def upload_folder_view(request):
    
    if request.method == 'POST':
    
        form = UploadFolderForm(request.POST, request.FILES)            
        analysis_form = OptionForm(request.POST) 

        if form.is_valid():
            # Process the uploaded files here
            files = request.FILES.getlist('folder')
            # Call your functions to process the Excel sheets here
            # ...
            return render(request, 'upload_success.html')
        
    else:
        form = UploadFolderForm()
        analysis_form = OptionForm()


    return render(request, 'dataupload.html', {'form': analysis_form, 'analysis_form':analysis_form})



def custom_function(request):
    print("starting ")
     # my_function()
    if request.method == "POST":
        print("running")
        analysis =  AnalysisRun(
            progress = 0.3
        )
        analysis.save()
        # Your custom function logic goes here
        # For example, you can perform database operations or any other task
        

        # return render(request, 'dataupload.html', {'form': form})
        return HttpResponse("Function executed successfully")
    return HttpResponse("Invalid request method")

def analyse(request):
    form = OptionForm()
    return render(request, 'your_template.html', {'form': form})