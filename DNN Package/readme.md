Step 1:
Install the DNN package by acknowledging that any use requires permission by Dr. Mark J. Embrechts (mark.embrechts@gmail.com). Using BBBackProp itself is free, provided the use of the package is acknowledged in any publication containing results obtained by BBBackProp.  The installation is self-explanatory by following the steps involved

Step 2:
Open an MS DOS (Command Prompt) window and create in the root directory the following file "cc.bat".  The content of this file is the one liner: cd c:\DNN.  Create a folder in the c:\DNN using the File Exporer.  Any results and datafiles appear in this folder.

Step 3:
The datafiles must be tab delimited files (can be created in Excel for example), where the attributes/features (x-variables) are arranged in columns (the recorded values for a particular x-variable are arranged in a particular column) and each data point (values for the individual x-variables) are arranged in a row. If there are M x-variables, say M = 18, the first 18 columns must contain the values of the x-variables.  The next, e.g. M+1 or 19th column, then contains the response (y-values to be predicted for a regression or class label for a classification problem).  The last column (M+2)th column contains the ID of the data point, starting from 1 -first row and (M+2)th column- and increments in steps of 1 to the last data point, i.e. if the dataset contains 10271 data points, the entry in the last row and (M+2)th column is 10271.

Step 4:
For a datafile to be loaded and modeled by BBBackProp, it must be of the form "MyData" and cannot contain any file extension, e.g. MyData.txt.  If the datafile was created by Excel and is saved as MyData.txt for example, use the File Exporer and delete ".txt".  The data file must be copied into the directory c:\DNN.

Step 5:
To run the BBBackProp, open an MS DOS (Command Prompt) and type cc.bat, which will change the directory to c:\DNN.

Step 6:
Type in the command mje MyData --MS, which generates a script MyData.bat.

Step 7:
Type in the command MyData.bat to run the script, which will then ask for details concerning the network architecture, e.g. the number of layers (input + number of hidden layers + output layer, e.g. 7 implies that there are 5 hidden layers). and the number of nodes per layer.  After specifying all relevent information, BBBackProp will train a DNN according to the network topology specified.


The license for using this package is "free" but requires consent by Dr. Embrechts and any results obtained that appear in a publication must acknowledge the use of BBBackProp.  This is OK for use within Dr. Barroso's lab of course. 

DNN package by Mark J Embrechts
