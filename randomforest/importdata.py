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






@receiver(post_save, sender=AnalysisRun)
def analysis_run_created(sender, instance, created, **kwargs):
    if len(instance.celllines.all()) > 0 and instance.inProgress == False:
        pass
        # Enqueue the Celery task to run in the background
        # process_analysis_run.delay(instance.id)
        # parameter_import()




# Function 1: parameter_import
def parameter_import():
    comp = ["Area", "BoundingBoxAA Length", 'BoundingBoxOO Length', 'Distance from Origin Ref',
    'Ellipticity (oblate)', 'Ellipticity (prolate)', 'Number of Triangles', 'Number of Voxels',     
    'Position Reference Frame',
      'Shortest Distance to Surfac', 
      'Sphericity', 'Volume']  # Replace this with your desired sheet names

    param_labels = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X',
        'BB OO Y', 'BB OO Z', 'Dist Origin', 'Oblate','Prolate',
        'Triangles', 'Voxels', 'Position X', 'Position Y', 'Position Z', 'Dist Surface',
    'Sphericity', 'Volume', 'CI', 'BI AA', 'BI OO', 'Polarity'] #Note: this variable gets added to and reordered

    analysis = AnalysisRun.objects.last()
    # comp = analysis.comp_options.split(',')

    analysis.stage ="Extracting and Processing Data"
    analysis.inProgress = True
    analysis.save()

    celllines = analysis.celllines.all()
    file_last_index = UploadedFolder.objects.last().id
    file_first_index = UploadedFolder.objects.first().id
    print(file_first_index)
    print(file_last_index)
    X = np.empty((0, 0))  
    y = []
    celllines = []
    object_id_list = []

    for i in range(file_first_index, file_last_index):
 
    # for i, file in enumerate(files):
        # Read the content of the UploadedFolder object into memory using io.BytesIO
        print(i)
        file  =  UploadedFolder.objects.get(id = i)
        active_file_data = io.BytesIO(file.folder.read())
        
        # Work with the file data in memory 

        # Get the sheet names from the file data in memory
        full_sheets = pd.ExcelFile(active_file_data).sheet_names
        
       
        # Filter the sheets
        sheets_index = []
        for keyword in comp:
            # sheets_index.append[idx for idx, name in enumerate(full_sheets) if any(name.lower().startswith(keyword))]
            if(keyword == 'Volume'):
                
                temp_sheets_index = [idx for idx, name in enumerate(full_sheets) if keyword.lower() == name.lower()]
                sheets_index.extend(temp_sheets_index)
                del(temp_sheets_index)
            
            elif(keyword == 'BoundingBoxOO Length'):
                temp_sheets_index = [idx for idx, name in enumerate(full_sheets) if keyword.lower() == name.lower()]
                sheets_index.extend(temp_sheets_index)
                del(temp_sheets_index)
            

            elif(keyword == 'BoundingBoxAA Length'):
                temp_sheets_index = [idx for idx, name in enumerate(full_sheets) if keyword.lower() == name.lower()]
                sheets_index.extend(temp_sheets_index)
                del(temp_sheets_index)
            
            else:
                temp_sheets_index = [idx for idx, name in enumerate(full_sheets) if keyword.lower() in name.lower()]
                sheets_index.extend(temp_sheets_index)
                del(temp_sheets_index)
                            
        
       


        #initialize X_temp
        X_temp = np.empty((0, 0))
        

        

        for k, var in enumerate(sheets_index):
            active_sheet = full_sheets[var]

        
            if "BoundingBox" in active_sheet:
                imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:C")
                temp = imported_table.to_numpy()
                del imported_table

                if X_temp.shape[0] == 0:
                    X_temp = temp
                    del temp

                else:
                    # Check if the number of rows in temp is the same as X_temp
                    if X_temp.shape[0] == temp.shape[0]:
                        X_temp = np.hstack([X_temp, temp])  # Append temp horizontally to X_temp  
                        del temp       
                     
                    else:
                        # Handle mismatch in the number of rows (e.g., raise an error or skip the temp array)
                        print("Mismatch in the number of rows. Skipping this temp array.")


            elif "Distance from Origin" in active_sheet or "Position" in active_sheet:
            # elif  "Position Reference Frame" in active_sheet:
                
                cellnum = 1
                try:
                    pattern = r"cell(\d+)"
                    cell_num = re.search(pattern, file.folder.name).group(1)
                except:
                    cell_num = int(re.search(r'Cell_(\d+)', file.folder.name).group(1))
                    # pattern = r"cell_(\d+)"
                    # cell_num = re.search(pattern, file.folder.name).group(1)

                if "Distance" in active_sheet:
                    imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:A,E")
                    temp_1 = imported_table.to_numpy()
                    del imported_table

                    headers = temp_1[0]
                    numeric_data = temp_1[1:]  
                    # Convert the last column to string data type
                    numeric_data[:, -1] = np.char.replace(numeric_data[:, -1].astype(str), " ", "")

                 
                    # Filter data where Time is equal to 1
                    filtered_data = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'cell{cell_num}']

                 
                    
                    if filtered_data.size == 0:
                            
                        filtered_data = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'ReferenceFrame{file.cellline}Cell{cell_num}']
                        # lookupindex = np.flatnonzero(np.core.defchararray.find(cell_num,numeric_data)!=-1)
                        # print(lookupindex)

                        if filtered_data.size == 0:
                            
                            filtered_data = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'Cell{cell_num}']


                    # Eliminate the last column
                    # filtered_data = filtered_data[:, :-1]

                    
                    # Create a new array with headers and filtered data
                    temp = np.vstack((headers, filtered_data))
                    del filtered_data
                    temp = temp[:, :-1]
                    # X_temp = np.hstack([X_temp, temp])

                    if X_temp.shape[0] == 0:
                        X_temp = temp
                        del temp

                    else:
                        # Check if the number of rows in temp is the same as X_temp
                        if X_temp.shape[0] == temp.shape[0]:
                            X_temp = np.hstack([X_temp, temp])  # Append temp horizontally to X_temp
                            del temp
                        else:
                            # Handle mismatch in the number of rows (e.g., raise an error or skip the temp array)
                            print("Mismatch in the number of rows. Skipping this temp array.")
                            print(file.folder.name)



                else:
                    #Read columns "A" to "C" and "G" from the Excel file
                    imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:C,G")
                    temp_1 = imported_table.to_numpy()
                    del imported_table
                    headers = temp_1[0]
                    numeric_data = temp_1[1:] 
                    
                    # Convert the last column to string data type
                    numeric_data[:, -1] = np.char.replace(numeric_data[:, -1].astype(str), " ", "")


                    # Filter data 
                    filtered_data = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'cell{cell_num}']
                    print(numeric_data[1])
                 
                    
                    if filtered_data.size == 0:
                            
                        filtered_data = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'ReferenceFrame{file.cellline}Cell{cell_num}']
                        # lookupindex = np.flatnonzero(np.core.defchararray.find(cell_num,numeric_data)!=-1)
                        # print(lookupindex)

                        if filtered_data.size == 0:
                            print(cell_num)
                            
                            filtered_data = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'Cell{cell_num}']


                    # Eliminate the last column
                    # filtered_data = filtered_data[:, :-1]
                    
                    # # Filter data where Time is equal to 1
                    # filtered_data_spaced = numeric_data[numeric_data[:, headers.tolist().index('ReferenceFrame')] == f'cell {cell_num}']


                    # Create a new array with headers and filtered data
                    temp = np.vstack((headers, filtered_data))
                    del filtered_data
                    temp = temp[:, :-1]


                    # try:
                    # X_temp = np.hstack([X_temp, temp])
                    # except:
                    #     pass
                    
                    if X_temp.shape[0] == 0:
                        X_temp = temp
                        del temp

                    else:
                        # Check if the number of rows in temp is the same as X_temp
                        if X_temp.shape[0] == temp.shape[0]:
                            X_temp = np.hstack([X_temp, temp])  # Append temp horizontally to X_temp
                            del temp
                        else:
                            # X_temp = np.hstack([X_temp, temp])
                            # Handle mismatch in the number of rows (e.g., raise an error or skip the temp array)
                            print("Mismatch in the number of rows. Skipping this temp array positions.")
                            print(file.folder.name)


            elif "Shortest Distance" in active_sheet:
                imported_table = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="D:D")
                surfdist_IDdata = imported_table.to_numpy()

                  
                cellnum = 1
                try:
                    pattern = r"cell(\d+)"
                    cell_num = re.search(pattern, file.folder.name).group(1)
                except:

                    cell_num = int(re.search(r'Cell_(\d+)', file.folder.name).group(1))

                # Determine if appropriate DAPI is presented in different ways
                surfdist_string1 = f"cell{cell_num} dapi"
                surfdist_string2 = f"dapi cell{cell_num}"
                surfdist_string3 = f"dapi {cell_num}"
                
                surfdist_string4 = f"cell{cell_num} nuc"
                surfdist_string5 = f"cell{cell_num} ko nuc"
                surfdist_string6 = f"cell {cell_num} wt nuc"
                surfdist_string7 = f"cell{cell_num} wt nuc"
                surfdist_string8 = f"{file.cellline.name} Cell {cell_num} Nucleus"
                surfdist_string9 = f"cell {cell_num} ko nuc"
                surfdist_string10 = f"NUCS"

                # Access the second item in the inner list (row 1, column 0)
                second_item = surfdist_IDdata[1, 0]
                print(second_item)
              
                # Import appropriate data
                if surfdist_string1 in second_item or surfdist_string2 in second_item or surfdist_string3 in second_item or surfdist_string4 in second_item or surfdist_string5 in second_item or surfdist_string6 in second_item or surfdist_string7 in second_item or surfdist_string8 in second_item or surfdist_string9 in second_item or surfdist_string10 in second_item:
                    
            
                    # Import 1 column for Distance to Surface
                    imported_data = pd.read_excel(active_file_data, sheet_name=active_sheet, usecols="A:A")
                    temp = imported_data.to_numpy()
                    del imported_data
                    # X_temp.extend(temp)
                    X_temp = np.hstack([X_temp, temp]) 
                    del temp
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
                        del temp
                    else:
                        # X_temp = np.hstack([X_temp, temp])
                        # Handle mismatch in the number of rows (e.g., raise an error or skip the temp array)
                        print("Mismatch in the number of rows. Skipping this temp array.")

                
            del active_sheet
        
   
        
    

        analysis.stage = "Parameter Calculations"
        analysis.save()
        if X_temp.shape[1] == 18:    
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
          
            # print(file.folder.name)
        del active_file_data
        del full_sheets
        del sheets_index
        del file
        del X_temp

        

    
    X = np.vstack(X)  # Convert the list of arrays into a single NumPy array
  
  
    del celllines
    timer = threading.Timer(3.0,parameter_calc,  args = [X,y,features, object_id_list])
    timer.start()
    print("function ended")
    del X
    del y
    del features
    del object_id_list
 
   

# Function 2: parameter_calc
def parameter_calc(X,y,features, objectID):

   
    
    analysis = AnalysisRun.objects.last()


    featureList =  features.tolist()
    figures = X.tolist()

    #######OPG Features Processing###########
    
    area= np.array([row[featureList.index('Area')] for row in figures])
    volume = np.array([row[featureList.index('Volume')] for row in figures])  
    bbaa_x = np.array([row[featureList.index('BoundingBoxAA Length X')] for row in figures])
    bbaa_y = np.array([row[featureList.index('BoundingBoxAA Length Y')] for row in figures])
    bbaa_z = np.array([row[featureList.index('BoundingBoxAA Length Z')] for row in figures])
    bboo_x = np.array([row[featureList.index('BoundingBoxOO Length A')] for row in figures])
    bboo_y = np.array([row[featureList.index('BoundingBoxOO Length B')] for row in figures])
    bboo_z = np.array([row[featureList.index('BoundingBoxOO Length C')] for row in figures])
    pos_x =  np.array([row[featureList.index('Position X Reference Frame')] for row in figures])
    
    pos_y =  np.array([row[featureList.index('Position Y Reference Frame')] for row in figures])
    pos_z =  np.array([row[featureList.index('Position Z Reference Frame')] for row in figures])
    dist_origin =  np.array([row[featureList.index('Distance from Origin Reference Frame')] for row in figures])
    dist_surface =  np.array([row[featureList.index('Shortest Distance to Surfaces')] for row in figures])
    voxels =  np.array([row[featureList.index('Number of Voxels')] for row in figures])
    sphericity =  np.array([row[featureList.index('Sphericity')] for row in figures])
    oblate =  np.array([row[featureList.index('Ellipticity (oblate)')] for row in figures])
    prolate =  np.array([row[featureList.index('Ellipticity (prolate)')] for row in figures])
    triangles =  np.array([row[featureList.index('Number of Triangles')] for row in figures])
    ci = (area ** 3) / (16 * (np.pi ** 2) * (volume ** 2))
    ci = ci.reshape(-1, 1)
    mbi_aa = bbaa_x / bbaa_z
    mbi_aa = mbi_aa.reshape(-1, 1)
    mbi_oo = bboo_x / bboo_z
    mbi_oo = mbi_oo.reshape(-1, 1)
    polarity = np.arctan2(pos_y, np.sqrt(pos_x ** 2 + pos_z ** 2))
    polarity = polarity.reshape(-1, 1)
  
    dist_origin = dist_origin.reshape(-1, 1)
    dist_surface = dist_surface.reshape(-1, 1)
    del figures


  


    cellnum = objectID.count(0)
    analysis.cellnum = cellnum
    # analysis.save()
    mmdist_data = []

    # try:
    posx_idx= featureList.index("Position X Reference Frame")
    posy_idx = featureList.index("Position Y Reference Frame")
    posz_idx = featureList.index("Position Z Reference Frame")

    start_index = [index for index, value in enumerate(objectID) if value == 0]

    for i in range(cellnum):
        cellstart = start_index[i]
        cellend = 0
        if i + 1 < cellnum:
            cellend = start_index[i + 1] - 1 
        else:
            cellend = len(objectID) - 1

     
        cellrange = np.arange(cellstart, cellend + 1 )
    
        current_mmdist_data = np.zeros((len(cellrange), len(cellrange)))
        
        for x in range(len(cellrange)):
            for z in range(len(cellrange)):
                if x == z:
                    current_mmdist_data[x, z] = 0
                    continue

                obj1_idx = cellrange[x]
                obj2_idx = cellrange[z]
            
                obj1_pos =  [
                    X[obj1_idx, posx_idx],
                    X[obj1_idx, posy_idx], 
                    X[obj1_idx,posz_idx]
                    ]

                obj2_pos = [
                    X[obj2_idx, posx_idx],
                    X[obj2_idx, posy_idx], 
                    X[obj2_idx,posz_idx]
                    ]
              
            

                

                mm_dist = np.sqrt((obj1_pos[0] - obj2_pos[0]) ** 2 +
                                (obj1_pos[1] - obj2_pos[1]) ** 2 +
                                (obj1_pos[2] - obj2_pos[2]) ** 2)
                


                current_mmdist_data[x, z] = mm_dist


    
    
        mmdist_data.append(current_mmdist_data)
    
    # Initialize empty lists for statistics
    min_mmdist = []
    max_mmdist = []
    mean_mmdist = []
    median_mmdist = []
    std_mmdist = []
    sum_mmdist = []
    skewness_mmdist = []
    kurtosis_mmdist = []
    # Iterate through mmdist_data
    for i, current_mmdist_data in enumerate(mmdist_data, start=1):
        
        current_mmdist_data = np.array(current_mmdist_data)  # Convert to NumPy array
        for j in range(len(current_mmdist_data)):
        
            obj_mmdist = current_mmdist_data[j, current_mmdist_data[j, :] != 0]  # Remove zeros
            
            
            min_mmdist.append(np.min(obj_mmdist))
            max_mmdist.append(np.max(obj_mmdist))
            mean_mmdist.append(np.mean(obj_mmdist))
            median_mmdist.append(np.median(obj_mmdist))
            std_mmdist.append(np.std(obj_mmdist))
            sum_mmdist.append(np.sum(obj_mmdist))
            skewness_mmdist.append(skew(obj_mmdist))
            kurtosis_mmdist.append(kurtosis(obj_mmdist))

    #Clearing memory
    del current_mmdist_data


    features =np.hstack([features,"min_mmdist","max_mmdist","mean_mmdist","median_mmdist","std_mmdist","sum_mmdist","skewness_mmdist","kurtosis_mmdist","sum/volume","sum/position",])
    
    X_dpg = np.hstack([
        np.array(min_mmdist).reshape(-1,1),np.array(max_mmdist).reshape(-1,1), np.array(mean_mmdist).reshape(-1,1), np.array(median_mmdist).reshape(-1,1),
        np.array(std_mmdist).reshape(-1,1),np.array(sum_mmdist).reshape(-1,1),np.array(skewness_mmdist).reshape(-1,1),np.array(kurtosis_mmdist).reshape(-1,1),  
        np.array(sum_mmdist/volume).reshape(-1,1), np.array(sum_mmdist/pos_z).reshape(-1,1), np.array(sum_mmdist*volume).reshape(-1,1) , np.array(sum_mmdist*pos_z).reshape(-1,1) ])

    features_dpg = np.hstack(["min_mmdist","max_mmdist","mean_mmdist","median_mmdist","std_mmdist","sum_mmdist","skewness_mmdist","kurtosis_mmdist","sum/volume","sum/position",])
    
    pos_x = pos_x.reshape(-1, 1)
    pos_y = pos_y.reshape(-1, 1)
    pos_z = pos_z.reshape(-1, 1)
    #Clear the data from memory
    del obj_mmdist


    # except:
    #     pass
  
    
    analysis.stage ="Random Forest Training"
    

 

    analysis.save()
    analysis = AnalysisRun.objects.last()
   


    del X
    timer = threading.Timer(1.0,train, args = [X_dpg, features_dpg,y,"dpg"])
    timer.start()   

    # timer2 = threading.Timer(200.0,kfda, args = [X_dpg, features_dpg,y,"dpg"])
    # timer2.start()
    # train(X_dpg, features_dpg,y,"dpg")
    # kfda(X_dpg, features_dpg, y,"dpg")

    X_opg = np.hstack([np.array(area).reshape(-1,1),np.array(volume).reshape(-1,1) ,np.array(bbaa_x).reshape(-1,1),np.array(bbaa_y).reshape(-1,1),np.array(bbaa_z).reshape(-1,1),np.array(bboo_x).reshape(-1,1),np.array(bboo_y).reshape(-1,1),np.array(bboo_z).reshape(-1,1),np.array(voxels).reshape(-1,1),np.array(sphericity).reshape(-1,1),np.array(oblate).reshape(-1,1),np.array(prolate).reshape(-1,1),np.array(triangles).reshape(-1,1),np.array(ci).reshape(-1,1),np.array(mbi_aa).reshape(-1,1),np.array(mbi_oo).reshape(-1,1)])
    features_opg = np.hstack(["Area","Volume","BBAA_X","BBAA_Y","BBAA_Z","BBOO_X","BBOO_Y","BBOO_Z","Voxels","Sphericity","Oblate","Prolate","Triangles","CI","BBAA_BI","BBOO_BI"])
    
    
    timer4 = threading.Timer(61.0,train, args = [X_opg, features_opg,y,"opg"])
    timer4.start()

    X_npg = np.hstack([polarity,pos_x,pos_y,pos_z,dist_origin,dist_surface])
    features_npg = np.hstack(["Polarity","Position_X","Position_Y","Position_Z","Dist Origin","Dist Surface"])
 
    timer4 = threading.Timer(120.0,train, args = [X_npg, features_npg,y,"npg"])
    timer4.start()

    timer5 = threading.Timer(180.0,train, args = [np.hstack([X_npg, X_dpg]), np.hstack([features_dpg, features_npg]),y,"npg_dpg"])
    timer5.start()

    timer6 = threading.Timer(240.0,train, args = [np.hstack([X_npg, X_opg]), np.hstack([features_npg, features_opg]),y,"npg_opg"])
    timer6.start()

    timer7 = threading.Timer(300.0,train, args = [np.hstack([X_dpg, X_opg]), np.hstack([features_dpg, features_opg]),y,"dpg_opg"])
    timer7.start()

    timer8 = threading.Timer(360.0,train, args = [np.hstack([X_dpg, X_opg,X_npg]), np.hstack([features_dpg, features_opg,features_npg]),y,"all"])
    timer8.start()


    #KFDA Sample
    # timer3 = threading.Timer(500.0,kfda, args = [X_opg, features_opg,y,"opg"])
    # timer3.start()
    print("secondary processing done")