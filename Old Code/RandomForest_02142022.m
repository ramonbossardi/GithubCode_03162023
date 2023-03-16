function RandomForest_12222022(celllines_color, celllines, dir, root)
%Code for the Data Analysis and Classification of Cell Lines Based on
%Object Parameters. This is general code that will be extended to specific
%cases later on

%Last Edited: 06/07/2021

clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

%~~PART 0: INITIALIZATION AND ALLOCATION OF GLOBAL VARIABLES~~
save_dir = [dir 'MATLAB Data'];
save_filename = [root '_ImportedIMARISData.mat'];

%~~PART 1: LOADING DATASET AND VARIABLES~~
progressbar([], [], 0, 0, 0) 

cd(save_dir)
imported = load(save_filename);

X = imported.X;
X_labels = imported.X_labels;
T_labels = imported.T_labels;
cellX_labels = imported.cellX_labels;
param_labels = imported.param_labels;
objectID = imported.objectID;
dpg_data = imported.dpg_data;
cell_list = imported.cell_list;

save_dir = [dir 'MATLAB Data'];
figure_dir = [dir 'Figures'];

figure_filename = [root '_Figure_'];
workspace_filename = [root '_Workspace.mat'];

%~~PART 2 - DEFINE PARAMETER SUBSETS~~
progressbar('MainScript', root, 'Classification','Defining Param', '')
progressbar([], [], .05, 0, 0) 

%OPG Subset
param_opg = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X','BB OO Y', 'BB OO Z',...
    'CI', 'Oblate','Prolate', 'BI AA', 'BI OO','Sphericity','Triangles','Volume', 'Voxels'];
param_idx_opg = find(contains(param_labels, param_opg));
X_opg = X(:,param_idx_opg);
param_labels_opg = param_labels(param_idx_opg);
progressbar([], [], .05, .15, 0) 

%NPG Subset
param_npg = ["Dist Origin", 'Position X', 'Position Y', 'Position Z', 'Dist Surface', 'Polarity'];
param_idx_npg = find(contains(param_labels, param_npg));
X_npg = X(:,param_idx_npg);
param_labels_npg = param_labels(param_idx_npg);
progressbar([], [], .05, .3, 0) 

%DPG Subset
param_dpg = ["Min Dist" 'Max Dist' 'Mean Dist' 'Median Dist' 'Std Dist' 'Sum Dist' 'Skewness Dist' ...
    'Kurtosis Dist' 'Sum/Vol Dist' 'Sum/Pos Z Dist' 'Sum*Vol Dist' 'Sum*Pos Z Dist'];
param_idx_dpg = find(contains(param_labels, param_dpg));
X_dpg = X(:,param_idx_dpg);
param_labels_dpg = param_labels(param_idx_dpg);
progressbar([], [], .05, .45, 0) 

%OPG + NPG Subset
param_opgnpg = [param_opg param_npg];
param_idx_opgnpg = find(contains(param_labels, param_opgnpg));
X_opgnpg = X(:,param_idx_opgnpg);
param_labels_opgnpg = param_labels(param_idx_opgnpg);
progressbar([], [], .05, .6, 0) 

%OPG + DPG Subset
param_opgdpg = [param_opg param_dpg];
param_idx_opgdpg = find(contains(param_labels,param_opgdpg));
X_opgdpg = X(:,param_idx_opgdpg);
param_labels_opgdpg = param_labels(param_idx_opgdpg);
progressbar([], [], .05, .75, 0) 

%NPG + DPG Subset
param_npgdpg = [param_npg param_dpg];
param_idx_npgdpg = find(contains(param_labels,param_npgdpg));
X_npgdpg = X(:,param_idx_npgdpg);
param_labels_npgdpg = param_labels(param_idx_npgdpg);


%~~PART 3: RANDOM FOREST CLASSIFICATION AND CONFUSION MATRIX PLOT~~
progressbar('MainScript', root, 'Classification', 'RF Training & Accuracy Assessment', '')
progressbar([], [], .3, 0, 0)
    [forest, forestCVClass, forestCVScore, forestCVErri] = cellline_randomforest(X, X_labels, param_labels, 'RF ~ All Param', 0); 
progressbar([], [], .3, .2, 0)
    [forest_opg, forestCVClass_opg, forestCVScore_opg, forestCVErri_opg] = cellline_randomforest(X_opg, X_labels, param_labels_opg, 'RF ~ OPG', 0);
progressbar([], [], .3, .35, 0)
    [forest_npg, forestCVClass_npg, forestCVScore_npg, forestCVErri_npg]  = cellline_randomforest(X_npg, X_labels, param_labels_npg, 'RF ~ NPG', 0);
progressbar([], [], .3, .50, 0)
    [forest_dpg, forestCVClass_dpg, forestCVScore_dpg, forestCVErri_dpg] = cellline_randomforest(X_dpg, X_labels, param_labels_dpg, 'RF ~ DPG', 0);
progressbar([], [], .3, .65, 0)
    [forest_opgnpg, forestCVClass_opgnpg, forestCVScore_opgnpg, forestCVErri_opgnpg] = cellline_randomforest(X_opgnpg, X_labels, param_labels_opgnpg, 'RF ~ OPG + NPG', 0);
progressbar([], [], .3, .80, 0)
    [forest_opgdpg, forestCVClass_opgdpg, forestCVScore_opgdpg, forestCVErri_opgdpg] = cellline_randomforest(X_opgdpg, X_labels, param_labels_opgdpg, 'RF ~ OPG + DPG', 0);
progressbar([], [], .3, .95, 0)
    [forest_npgdpg, forestCVClass_npgdpg, forestCVScore_npgdpg, forestCVErri_npgdpg] = cellline_randomforest(X_npgdpg, X_labels, param_labels_npgdpg, 'RF ~ NPG + DPG', 0);

%~~PART 4: RANDOM FOREST ROC CURVE~~
progressbar('MainScript', root, 'Classification', 'ROC Assessment', '')

figure('Name', 'ROC Curve 1', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);    
progressbar([], [], .6, 0, 0)
    cellline_auc = cellline_roc(X_labels, forestCVClass, forestCVScore, 'ROC ~ All Param');
    
figure('Name', 'ROC Curve 2', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);   
progressbar([], [], .6, .2, 0) 
    cellline_auc_opg = cellline_roc(X_labels, forestCVClass_opg, forestCVScore_opg, 'ROC ~ OPG');
    
figure('Name', 'ROC Curve 3', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);   
progressbar([], [], .6, .2, 0) 
    cellline_auc_npg = cellline_roc(X_labels, forestCVClass_npg, forestCVScore_npg, 'ROC ~ NPG');
    
figure('Name', 'ROC Curve 4', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);   
progressbar([], [], .6, .35, 0)
    cellline_auc_dpg = cellline_roc(X_labels, forestCVClass_dpg, forestCVScore_dpg, 'ROC ~ DPG');
    
figure('Name', 'ROC Curve 5', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);   
progressbar([], [], .6, .5 , 0)
    cellline_auc_opgnpg = cellline_roc(X_labels, forestCVClass_opgnpg, forestCVScore_opgnpg, 'ROC ~ OPG + NPG');
    
figure('Name', 'ROC Curve 6', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);   
progressbar([], [], .6, .65, 0) 
    cellline_auc_opgdpg = cellline_roc(X_labels, forestCVClass_opgdpg, forestCVScore_opgdpg, 'ROC ~ OPG + DPG');
    
figure('Name', 'ROC Curve 7', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);   
progressbar([], [], .6, .80, 0)  
    cellline_auc_npgdpg = cellline_roc(X_labels, forestCVClass_npgdpg, forestCVScore_npgdpg, 'ROC ~ NPG + DPG');

%~~PART 5: RELATIVE PREDICTOR IMPORTANCE CALCULATION~~
progressbar('MainScript', root, 'Classification', 'Predictor Importance', '')

progressbar([], [], .8, 0, 0)  
    imp = cellline_predictorimportance(forest, param_labels, 'Predictor Importance ~ All Param', 1);
progressbar([], [], .8, .1, 0) 
    imp_opg = cellline_predictorimportance(forest_opg, param_labels_opg, 'Predictor Importance ~ OPG',1);
progressbar([], [], .8, .25, 0) 
    imp_npg = cellline_predictorimportance(forest_npg, param_labels_npg, 'Predictor Importance ~ NPG',1);
progressbar([], [], .8, .4, 0) 
    imp_dpg = cellline_predictorimportance(forest_dpg, param_labels_dpg, 'Predictor Importance ~ DPG',1);
progressbar([], [], .8, .55, 0) 
    imp_opgnpg = cellline_predictorimportance(forest_opgnpg, param_labels_opgnpg, 'Predictor Importance ~ OPG + NPG', 1);
progressbar([], [], .8, .70, 0) 
    imp_opgdpg = cellline_predictorimportance(forest_opgdpg, param_labels_opgdpg, 'Predictor Importance ~ OPG + DPG', 1);
progressbar([], [], .8, .85, 0) 
    imp_npgdpg = cellline_predictorimportance(forest_npgdpg, param_labels_npgdpg, 'Predictor Importance ~ NPG + DPG',1);


%~~PART 6A: SAVING FIGURES AS IMAGES~~
progressbar([], [], .90, 0, 0) 
cd(figure_dir)
cellline_savefigures();

%~~PART 6B: EXPORT WORKSPACE~~
progressbar([], [], .95, 0, 0) 

cd(save_dir)
save(workspace_filename);

%~~FUNCTION DEFINITIONS~~
function [forest, forestCVClass, forestCVScore, forestCVErr_i] = cellline_randomforest(X, X_labels, param_labels, fig_title, skipconfusion)
    progressbar([], [], [], [], 0) 
    
    
    tic %tic and toc are statements that allow for time tracking
    rng('default');  %Setting the rng ensures reproducibility
    
    t = templateTree('Reproducible', true, 'Prune', 'off', 'PruneCriterion', 'error', 'SplitCriterion', 'gdi'); 
    forest = fitcensemble(X, X_labels, 'Method', 'Bag', 'Learners', t,...
        'PredictorNames', param_labels); %Random Forest Algorithm
    
    progressbar([], [], [], [], .2) 
    forestCV = crossval(forest); %10-Fold Cross Validation

    progressbar([], [], [], [], .5) 
    forestCVErr = kfoldLoss(forestCV); %Random Forest Algorithm Validation Error
    forestCVErr_i= kfoldLoss(forestCV, 'Mode', 'individual');
    [forestCVClass, forestCVScore] = kfoldPredict(forestCV); %Random Forest Algorithm Validation Prediction
    
    time = toc; %record the elapsed time
    progressbar([], [], [], [], .7) 

    if skipconfusion == 0 %the confusion matrix could be skipped if desired
        figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.4 0.6]);
        
        cm = confusionchart(cellstr(X_labels), forestCVClass); %confusion matrix of validation data
        title([fig_title, newline, 'CV Accuracy: ', num2str(100-(forestCVErr*100)),... 
            '%', newline, 'Time: ', num2str(time), 's'])
        cm.FontName = 'Calibri';
        cm.FontSize = 12;
        cm.GridVisible = 'off';
    end
end
function auc_data = cellline_roc(X_labels, forestCVClass, forestCVScore, fig_title)
    progressbar([], [], [], [], 0) 
    rocObj = rocmetrics(X_labels, forestCVScore, sort(celllines));

    progressbar([], [], [], [], .5) 
    plot(rocObj)
    title(fig_title);
    auc_data = rocObj.AUC;                                                                                                                                                                                                                                                                                                                           
end

function imp = cellline_predictorimportance(forest, param_labels, fig_title, skipfigure)
    progressbar([], [], [], [], 0) 
    %This statement enables parallel computing which can speed up this
    %segment of the code
    options = statset('UseParallel',true); 
    
    %The predictor importance is determine through Out-of-Bag Permuted
    %Predicter Importance, a process that allows for relatively accurate
    %analysis of predictor importance. This algorithm also works well if
    %one of the variables were to theorectically not be continous in the future 
    imp = oobPermutedPredictorImportance(forest,'Options',options);
    
    %the bar graph can be skipped if desired
    if skipfigure == 0
        %The statements below plot the predictor importance results on a
        %bar graph
        progressbar([], [], [], [], .5) 

        bar(categorical(param_labels), imp)
        title(fig_title);
        ylabel('Estimates');
        xlabel('Predictors');
    end
end 

function cellline_savefigures()
    
    %this array contains all the figures currently present at this point in
    %the code. This will allows these to be saved
    allfigures = findobj( 'Type', 'Figure');
    
    %for all the figures
    for i = 1:length(allfigures)
        current_fig = allfigures(i);
        %the 'Name' of the figure correlates to the naming at the top of
        %the window
        fig_name = current_fig.Name;

        progressbar([], [], [], (i-1)/length(allfigures), 0)
        
        %Note that we do not want to save progress bars. These have no
        %title, so these can be accounted for by the statement below
        if (strcmp(fig_name, '') || contains(fig_name, '%'))
            continue;
        end
        
        %We use the title of the figure to alter the filename of the figure
        %once saved
        adjusted_name = strrep(fig_name,'~', '-');
        adjusted_name = strrep(adjusted_name ,' ', '');
        
        %Save the figure as a .m file and 
        saveas(current_fig, [figure_filename adjusted_name], 'm') 
        saveas(current_fig, [figure_filename adjusted_name], 'png') 
    end
end
end

