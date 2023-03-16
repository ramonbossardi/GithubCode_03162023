function MATLABDataExport_06232021_CellNucEdit(dir, root)

clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames')

progressbar([], [], 0, 0, 0) 

workspace_dir = [dir 'MATLAB Data'];
workspace_filename = [root '_Workspace.mat'];

cd(workspace_dir)
M = load(workspace_filename);

%~~PART 6A: EXPORTING MAIN DATA TO EXCEL~~
%Main Data Exportation
progressbar([], [], .1, 0, 0)
cellline_completedataexport(M.X, M.X_labels, M.param_labels, M.objectID, M.celllines, ...
    M.forestCVErri, M.imp, M.forestCVScore, M.cellline_auc , [root '_Full']);
progressbar([], [], .45, 0, 0)
cellline_completedataexport(M.X_cell, M.X_labels, M.param_labels_cell, M.objectID, M.celllines, ...
    M.forestCVErri_cell, M.imp_cell, M.forestCVScore_cell, M.cellline_auc_cell , [root '_Cell']);
progressbar([], [], .8, 0, 0)
cellline_completedataexport(M.X_nuc, M.X_labels, M.param_labels_nuc, M.objectID, M.celllines, ...
    M.forestCVErri_nuc, M.imp_nuc, M.forestCVScore_nuc, M.cellline_auc_nuc , [root '_Nuc']);

progressbar([], [], .95, 0, 0)
cellline_altdataexport(M.X, M.X_labels, M.objectID, M.param_labels, M.celllines, [root '_Full_Alt']);
end

%cellline_dataexport: exporting desired data to an outside Excel form for further analysis.
function cellline_completedataexport(X, X_labels, param_labels, objectID, celllines, ...
    forestCVErri, imp, forestCVScore, cellline_auc , filename)
    progressbar([], [], [], 0)
    mkdir(filename)
    cd(filename)
    
    progressbar([], [], [], .05)
    T1 = cell2table([cellstr(X_labels) num2cell(objectID) num2cell(X)]);
    T1.Properties.VariableNames = cellstr(['Cellline' 'Object ID #' param_labels]);
    writetable(T1, 'Dataset.csv')
    
    progressbar([], [], [], .65)
    T2 = cell2table([num2cell([1:10].') num2cell((1-forestCVErri)*100)]);
    T2.Properties.VariableNames = cellstr(['kFold' "Accuracy"]);
    writetable(T2, 'kFoldAccuracy.csv')
    
    progressbar([], [], [], .70)
    T3 = cell2table([cellstr(param_labels.') num2cell(imp.')]);
    T3.Properties.VariableNames = cellstr(['Parameter' "Relative Predictor Importance"]);
    writetable(T3, 'PredictorImp.csv')
    
    progressbar([], [], [], .75)
    T4 = cell2table([cellstr(param_labels.') num2cell(normalize(imp, 'range').')]);
    T4.Properties.VariableNames = cellstr(['Parameter' "Normalized Predictor Importance"]);
    writetable(T4, 'NormPredictorImp.csv')
    
    progressbar([], [], [], .90)
    T5 = cell2table([cellstr(X_labels) num2cell(objectID) num2cell(forestCVScore)]);
    T5.Properties.VariableNames = cellstr(['True Label' 'Object ID #' celllines]);
    writetable(T5, 'ROCData.csv')
    
    progressbar([], [], [], .95)
    T6 = cell2table([cellstr(celllines.') num2cell(cellline_auc)]);
    T6.Properties.VariableNames = cellstr(['Positive Class' "Area Under Curve"]);
    writetable(T6, 'ROCData_AUC.csv')
    
    cd ../
end
function cellline_altdataexport(X, X_labels, objectID, param_labels, celllines, filename)
    param_labels_sheetname = strrep(param_labels, '/', ' Divided By ');
    param_labels_sheetname = strrep(param_labels_sheetname, '*', ' x ');
    progressbar([], [], [], 0)
    
    mkdir(filename)
    cd(filename)
    
    %Slide 2 - 34 Parameters Organized by Cell Lines
    progressbar([], [], [], 1/8, 0)
    for i = 1:length(celllines)
        progressbar([], [], [], [], (i-1)/length(celllines))
        cl_range = contains(X_labels, celllines(i));

        A1 = cell2table([cellstr(X_labels(cl_range)) num2cell(objectID(cl_range)) num2cell(X(cl_range,:))]);
        A1.Properties.VariableNames = cellstr(['Cellline' 'Object ID #' param_labels]);
        writetable(A1, strcat(celllines(i), 'Data.csv'))
    end
    
    %Slide 5 - LN of Data
    progressbar([], [], [], 6/8, 0)
    for i = 1:length(celllines)
        progressbar([], [], [], [], (i-1)/length(celllines))
        cl_range = contains(X_labels, celllines(i));
        
        A6 = cell2table([cellstr(X_labels(cl_range)) num2cell(objectID(cl_range)) num2cell(log(X(cl_range,:)))]);
        A6.Properties.VariableNames = cellstr([" " 'Object ID #' param_labels]);
        writetable(A6,  strcat('ln', celllines(i), 'Data.csv'))
    end

    cd ../
end