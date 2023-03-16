clear
clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

progressbar('Obj Exportation', 'CL Exportation')

dataset_modality = 'EXAMPLE'; %microscopy modality of the dataset (i.e. Fixed2D, Live2D, Fixed3D)

dataset_obj = {'ERC', 'Mito', 'ERCMitoInt'}; %object of the dataset (i.e. Mito, Endo, SCA)
workspace_dir_cell= {"C:\Users\jagol\OneDrive\Documents\MATLAB\ML Scripts\Datasets\Live2D 5CL\ERC 5CL ko+wt\MATLAB Data\Live2D5CL-ERC_Workspace.mat",...
    "C:\Users\jagol\OneDrive\Documents\MATLAB\ML Scripts\Datasets\Live2D 5CL\Mito 5CL ko+wt\MATLAB Data\Live2D5CL-Mito_Workspace.mat",...
    "C:\Users\jagol\OneDrive\Documents\MATLAB\ML Scripts\Datasets\Live2D 5CL\ERCMitoInt 5CL ko+wt\MATLAB Data\Live2D5CL-SCA-Nonpooled-AllTP_Workspace.mat"}; %full path name of that dataset's workspace (found under the MATLAB Data folder)

mkdir('EXAMPLEKrugerData') %make file to put new files in
cd('EXAMPLEKrugerData')

for i = 1:length(workspace_dir_cell) %for every object type
    progressbar((i-1)/length(workspace_dir_cell), [])
    
    %load object's workspace variables
    A = load(workspace_dir_cell{i});
    X = A.X;
    X_labels = A.X_labels;
    param_labels = A.param_labels;
    celllines = A.celllines;

    for j = 1:length(celllines)  %for every cellline
        progressbar([], ((i-1)/length(celllines)))
        
        %limit dataset to that cellline
        cl_range = contains(X_labels, celllines(j));
        
        %write nonblinded .csv
        A1 = cell2table(num2cell(X(cl_range,:)));
        A1.Properties.VariableNames = cellstr(param_labels);
        writetable(A1, append(dataset_modality,' ', dataset_obj{i}, ...
            ' ', celllines(j), ' Dataset.csv'))
    end
end

progressbar(1)

mkdir('BlindedData') %make file to put new files in
for k = randperm(length(workspace_dir_cell))

end






