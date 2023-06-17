Step 1: 
Copy all Matlab files including the comma delimited (*.csv) data files in a single directory

Step 2:
Run Matlab (R2021 version or later)

Step 3:
Open the ReadData.m file in Matlab and change the filename (currently 3D_SCA_NDPG_Dataset_Data.csv) to the datafile containing the dataset that need to be classified (default is a 4 class classification)

Step 4:
Open the ClassifyCancerData.m file in Matlab and run it.  If the ranges for the kFDA hyperparameters need to be adjusted to search for best performing model (evaluated on the testing data), open GetHyperParameters.m and change the ranges in lines 7 (for the regularization parameter alpha) and 9 (for the kernel parameter sigma).  Usually, the kernel parameter is more important for influencing the classification accuracy.
