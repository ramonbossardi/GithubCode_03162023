import gc
from kFDA.train import kfda
from background_task import background
import io
import os
import glob
import pandas as pd
import numpy as np
from scipy.stats import skew, kurtosis
import re
import numpy as np
from randomforest.models import UploadedFolder,AnalysisRun
from randomforest.train import train
from scipy.stats import skew, kurtosis
from django.db.models.signals import post_save
from django.dispatch import receiver
import asyncio
from .tasks import process_analysis_run 
import threading 
from OTCCPScript.restartheroku import restart_heroku_dynos



comp = ["Area", "BoundingBoxAA Length", 'BoundingBoxOO Length', 'Distance from Origin Reference Frame',
    'Ellipticity (oblate)', 'Ellipticity (prolate)', 'Number of Triangles', 'Number of Voxels',     
    'Position Reference Frame', 'Shortest Distance to Surfac', 'Sphericity', 'Volume']  # Replace this with your desired sheet names

param_labels = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X',
    'BB OO Y', 'BB OO Z', 'Dist Origin', 'Oblate','Prolate',
    'Triangles', 'Voxels', 'Position X', 'Position Y', 'Position Z', 'Dist Surface',
'Sphericity', 'Volume', 'CI', 'BI AA', 'BI OO', 'Polarity'] #Note: this variable gets added to and reordered


@receiver(post_save, sender=AnalysisRun)
def analysis_run_created(sender, instance, created, **kwargs):
    if len(instance.celllines.all()) > 0 and instance.inProgress == False:
        pass
        # Enqueue the Celery task to run in the background
        # process_analysis_run.delay(instance.id)
        # parameter_import()




# Function 1: parameter_import
def parameter_import():
    analysis = AnalysisRun.objects.last()
    # comp = analysis.comp_options.split(',')
    analysis.stage ="Extracting and Processing Data"
    analysis.inProgress = True
    analysis.save()

    celllines = analysis.celllines.all()
    
    X = np.empty((0, 0))  
    y = []
    X_list = []  
    X_labels = []
    cell_list = []
    celllines = []
    object_id_list = []


 
    for file in UploadedFolder.objects.filter(cellline__in=celllines):
   
        # Read the content of the UploadedFolder object into memory using io.BytesIO
        active_file_data = io.BytesIO(file.folder.read())
        
        # Work with the file data in memory 

        # Get the sheet names from the file data in memory
        full_sheets = pd.ExcelFile(active_file_data).sheet_names
        
       
        # Filter the sheets
        sheets_index = []
        for keyword in comp:
            # sheets_index.append[idx for idx, name in enumerate(full_sheets) if any(name.lower().startswith(keyword))]
            temp_sheets_index = [idx for idx, name in enumerate(full_sheets) if keyword.lower() in name.lower()]

            sheets_index.extend(temp_sheets_index)
  
        
       


        #initialize X_temp
        X_temp = np.empty((0, 0))
        

        

        for k, var in enumerate(sheets_index):
            active_sheet = full_sheets[var]
       
            if "BoundingBox" in active_sheet:
                imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:C")
                temp = imported_table.to_numpy()
                if X_temp.shape[0] == 0:
                    X_temp = temp

                else:
                    # Check if the number of rows in temp is the same as X_temp
                    if X_temp.shape[0] == temp.shape[0]:
                        X_temp = np.hstack([X_temp, temp])  # Append temp horizontally to X_temp                    
                        # print(X_temp)
                    else:
                        # Handle mismatch in the number of rows (e.g., raise an error or skip the temp array)
                        print("Mismatch in the number of rows. Skipping this temp array.")


            elif "Distance from Origin" in active_sheet or "Position" in active_sheet:
            # elif  "Position Reference Frame" in active_sheet:
                
                pattern = r"cell(\d+)"
                cell_num = re.search(pattern, file.folder.name).group(1)
                
                if "Distance" in active_sheet:
                    imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:A,E")
                    temp_1 = imported_table.to_numpy()

                    headers = temp_1[0]
                    numeric_data = temp_1[1:]  

                    
                    # Convert the last column to string data type
                    numeric_data[:, -1] = np.char.replace(numeric_data[:, -1].astype(str), " ", "")

                    
                    # Filter data 0where Time is equal to 1
                    filtered_data = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'cell{cell_num}']

                    # Eliminate the last column
                    # filtered_data = filtered_data[:, :-1]

                    
                    # Create a new array with headers and filtered data
                    temp = np.vstack((headers, filtered_data))
                    temp = temp[:, :-1]
                    # X_temp = np.hstack([X_temp, temp])

                    if X_temp.shape[0] == 0:
                        X_temp = temp

                    else:
                        # Check if the number of rows in temp is the same as X_temp
                        if X_temp.shape[0] == temp.shape[0]:
                            X_temp = np.hstack([X_temp, temp])  # Append temp horizontally to X_temp
                        else:
                            # Handle mismatch in the number of rows (e.g., raise an error or skip the temp array)
                            print("Mismatch in the number of rows. Skipping this temp array.")


                else:
                    #Read columns "A" to "C" and "G" from the Excel file
                    imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:C,G")
                    temp_1 = imported_table.to_numpy()
                    
                    headers = temp_1[0]
                    numeric_data = temp_1[1:] 
                    
                    # Convert the last column to string data type
                    numeric_data[:, -1] = np.char.replace(numeric_data[:, -1].astype(str), " ", "")


                    # Filter data where Time is equal to 1
                    filtered_data = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'cell{cell_num}']

                    # Eliminate the last column
                    # filtered_data = filtered_data[:, :-1]
                    
                    # # Filter data where Time is equal to 1
                    # filtered_data_spaced = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'cell {cell_num}']


                    # Create a new array with headers and filtered data
                    temp = np.vstack((headers, filtered_data))
                    temp = temp[:, :-1]


                    # try:
                    # X_temp = np.hstack([X_temp, temp])
                    # except:
                    #     pass
                    
                    if X_temp.shape[0] == 0:
                        X_temp = temp

                    else:
                        # Check if the number of rows in temp is the same as X_temp
                        if X_temp.shape[0] == temp.shape[0]:
                            X_temp = np.hstack([X_temp, temp])  # Append temp horizontally to X_temp
                        else:
                            # X_temp = np.hstack([X_temp, temp])
                            # Handle mismatch in the number of rows (e.g., raise an error or skip the temp array)
                            print("Mismatch in the number of rows. Skipping this temp array.")


            elif "Shortest Distance" in active_sheet or "Position" in active_sheet:
                imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="D:D")
                surfdist_IDdata = imported_table.to_numpy()

                  
                pattern = r"cell(\d+)"
                cell_num = re.search(pattern, file.folder.name).group(1)
                
                # Determine if appropriate DAPI is presented in different ways
                surfdist_string1 = f"cell{cell_num} dapi"
                surfdist_string2 = f"dapi cell{cell_num}"
                surfdist_string3 = f"dapi {cell_num}"
                # Access the second item in the inner list (row 1, column 0)
                second_item = surfdist_IDdata[1, 0]

              
                # Import appropriate data
                if surfdist_string1 in second_item or surfdist_string2 in second_item or surfdist_string3 in second_item:
                    
                    # Import 1 column for Distance to Surface
                    imported_data = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:A")
                    temp = imported_data.to_numpy()
                    # X_temp.extend(temp)
                    X_temp = np.hstack([X_temp, temp]) 
                    dapi_import = 1
                else:
                    pass
                
            
            else:
                imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:A")
                temp = imported_table.to_numpy()
                
               
                if X_temp.shape[0] == 0:
                    X_temp = temp

                else:
                    # Check if the number of rows in temp is the same as X_temp
                    if X_temp.shape[0] == temp.shape[0]:
                        X_temp = np.hstack([X_temp, temp])  # Append temp horizontally to X_temp
                    else:
                        # X_temp = np.hstack([X_temp, temp])
                        # Handle mismatch in the number of rows (e.g., raise an error or skip the temp array)
                        print("Mismatch in the number of rows. Skipping this temp array.")

              
         
        
   
        
    

        analysis.stage = "Parameter Calculations"
        analysis.save()
      
                

        if X_temp.shape[1] == 17:    
            features = X_temp[0]
            X_temp = X_temp[1:]
            num_rows = X_temp.shape[0]
            # Generate a column vector of the specified rows number to get the ids for each object in the array
            column_vector = np.arange(num_rows).reshape(-1, 1)
            object_id_list.extend(column_vector.ravel().tolist())

            try:
                y_temp = np.array([file.cellline.name for _ in range(num_rows)])
                y = np.hstack([y, y_temp])
            except:
                y= np.array([file.cellline.name for _ in range(num_rows)]) 
            


            if X.shape[0] == 0:
                X = X_temp

            else:
        
                X = np.concatenate((X, X_temp), axis=0)
        
    
        del active_file_data
        del full_sheets
        del file

        

    
    X = np.vstack(X)  # Convert the list of arrays into a single NumPy array
  
    # X_labels = np.vstack(X_labels).flatten()


    volume_idx = np.flatnonzero(param_labels == "Volume")  # Correct the param_labels check
    mask = X[:, volume_idx] >= 0
    X_new = X[mask]
    # shutil.rmtree(temp_dir)
    # return X

    # Clear the memory
    # del files
    del volume_idx
    del mask
    del X_list 
    del X_temp
    del celllines
    # parameter_calc(X,y,features, object_id_list) 
   
    # train(X,y)
    return X_new, X_labels,  cell_list
