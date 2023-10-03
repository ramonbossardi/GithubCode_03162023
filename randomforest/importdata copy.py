import io
import os
import glob
import pandas as pd
import numpy as np
from scipy.stats import skew, kurtosis
import re
import numpy as np
from randomforest.models import UploadedFolder
from randomforest.train import train
from scipy.stats import skew, kurtosis


comp = ["Area", "BoundingBoxAA Length", 'BoundingBoxOO Length', 'Distance from Origin Reference Frame',
    'Ellipticity (oblate)', 'Ellipticity (prolate)', 'Number of Triangles', 'Number of Voxels',     
    'Position Reference Frame', 'Shortest Distance to Surfac', 'Sphericity', 'Volume']  # Replace this with your desired sheet names

param_labels = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X',
    'BB OO Y', 'BB OO Z', 'Dist Origin', 'Oblate','Prolate',
    'Triangles', 'Voxels', 'Position X', 'Position Y', 'Position Z', 'Dist Surface',
'Sphericity', 'Volume', 'CI', 'BI AA', 'BI OO', 'Polarity'] #Note: this variable gets added to and reordered

def extract_cell_number(active_file, match):
    cellnum_filename = active_file.replace(match, '')
    cellnum_str = re.findall(r'cell\d*', cellnum_filename)
    
    if len(cellnum_str) > 0:
        cellnum = float(re.findall(r'\d+', cellnum_str[0])[0])
    else:
        cellnum = None
    
    return cellnum

# Function 1: parameter_import
def parameter_import():
    
    files = UploadedFolder.objects.all()
    
    X = np.empty((0, 0))  
    y = []
    X_list = []  
    X_labels = []
    cell_list = []
    celllines = []
    object_id_list = []


    def process_file(file):
    X_temp = None
    for keyword in comp:
        with io.BytesIO(file.folder.read()) as active_file_data:
            full_sheets = pd.ExcelFile(active_file_data).sheet_names
            sheets_index = [idx for idx, name in enumerate(full_sheets) if keyword.lower() in name.lower()]

        for var in sheets_index:
            active_sheet = full_sheets[var]
    for i, file in enumerate(files):
   
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
  
        
        #Close the file in memory
        #     active_file_data.close


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
                    X_temp = np.hstack([X_temp, temp])
                    # except:
                    #     pass

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

              
         
        

        
    

        
      
                
        active_file_data.close

        
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
        

    
        try:  
            X = np.concatenate((X, X_temp), axis=0)
            
            # X.append(X_temp)
        except:
            
            X = X_temp 
        # Example dimensions check




    X = np.vstack(X)  # Convert the list of arrays into a single NumPy array
  
    # X_labels = np.vstack(X_labels).flatten()


    volume_idx = np.flatnonzero(param_labels == "Volume")  # Correct the param_labels check
    mask = X[:, volume_idx] >= 0
    X_new = X[mask]
    
    # shutil.rmtree(temp_dir)
    # return X

   
    parameter_calc(X,y,features, object_id_list)    
    # train(X,y)
    return X_new, X_labels,  cell_list

# Function 2: parameter_calc
def parameter_calc(X,y,features, objectID):
    

    featureList =  features.tolist()
    figures = X.tolist()
     
    area= np.array([row[featureList.index('Area')] for row in figures])
    volume = np.array([row[featureList.index('Volume')] for row in figures])  
    bbaa_x = np.array([row[featureList.index('BoundingBoxAA Length X')] for row in figures])
    bbaa_z = np.array([row[featureList.index('BoundingBoxAA Length Z')] for row in figures])
    bboo_x = np.array([row[featureList.index('BoundingBoxOO Length A')] for row in figures])
    bboo_z = np.array([row[featureList.index('BoundingBoxOO Length C')] for row in figures])
    pos_x =  np.array([row[featureList.index('Position X Reference Frame')] for row in figures])
    pos_y =  np.array([row[featureList.index('Position Y Reference Frame')] for row in figures])
    pos_z =  np.array([row[featureList.index('Position Z Reference Frame')] for row in figures])



    ci = (area ** 3) / (16 * (np.pi ** 2) * (volume ** 2))
    ci = ci.reshape(-1, 1)
    mbi_aa = bbaa_x / bbaa_z
    mbi_aa = mbi_aa.reshape(-1, 1)
    mbi_oo = bboo_x / bboo_z
    mbi_oo = mbi_oo.reshape(-1, 1)
    polarity = np.arctan2(pos_y, np.sqrt(pos_x ** 2 + pos_z ** 2))
    polarity = polarity.reshape(-1, 1)
    
    posx_idx= featureList.index("Position X Reference Frame")
    posy_idx = featureList.index("Position Y Reference Frame")
    posz_idx = featureList.index("Position Z Reference Frame")
  
    X_new = np.hstack([X, ci, mbi_aa, mbi_oo, polarity])

    cellnum = objectID.count(0)
    mmdist_data = []

    start_index = [index for index, value in enumerate(objectID) if value == 0]

    for i in range(cellnum):
        cellstart = start_index[i]
        cellend = start_index[i + 1] - 1 if i + 1 < cellnum else len(objectID) - 1
 
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

    
    X_new = np.hstack([
        X_new, np.array(min_mmdist).reshape(-1,1),np.array(max_mmdist).reshape(-1,1), np.array(mean_mmdist).reshape(-1,1), np.array(median_mmdist).reshape(-1,1),
        np.array(std_mmdist).reshape(-1,1),np.array(sum_mmdist).reshape(-1,1),np.array(skewness_mmdist).reshape(-1,1),np.array(kurtosis_mmdist).reshape(-1,1),  
        np.array(sum_mmdist/volume).reshape(-1,1), np.array(sum_mmdist/pos_z).reshape(-1,1), np.array(sum_mmdist*volume).reshape(-1,1) , np.array(sum_mmdist*pos_z).reshape(-1,1) ])
    # min_mmdist = np.array(min_mmdist).reshape(-1, 1)
    # X_new = np.hstack([X_new, min_mmdist])
    print(min_mmdist)
    train(X_new, y)

