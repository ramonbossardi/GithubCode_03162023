function MDDRStageIICode_03032023(celllines_color, celllines, dir, root, progress)
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
progressbar(progress, 0.33, 0, 0, 0) 

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
progressbar(progress, 0.33, .05, 0, 0) 

%OPG Subset
param_opg = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X','BB OO Y', 'BB OO Z',...
    'CI', 'Oblate','Prolate', 'BI AA', 'BI OO','Sphericity','Triangles','Volume', 'Voxels'];
param_npg = ["Dist Origin", 'Position X', 'Position Y', 'Position Z', 'Dist Surface', 'Polarity'];
param_opgnpg = [param_opg param_npg];
param_idx_opgnpg = find(contains(param_labels, param_opgnpg));
X_opgnpg = X(:,param_idx_opgnpg);
param_labels_opgnpg = param_labels(param_idx_opgnpg);
progressbar(progress, 0.33, .05, .6, 0) 

X_og = [X_opgnpg(:, 1:11) X_opgnpg(:, 13:end)];
param_labels_og = [param_labels_opgnpg(1:11) param_labels_opgnpg(:, 13:end)];
y = contains(X_labels, ["MCF10A", "MDA231", "T47D"]);
X_labels_og = X_labels(y);
X_og = X_og(y, :);

X_op1 = X_opgnpg(y,:);
[coeff, X_pca] = pca(X_og);
pca_labels = append('Var', string(1:length(param_labels_og)));

[X_p1, rm_p1] = rmoutliers(X_og, "mean", "ThresholdFactor", 3); X_labels_p1 = X_labels_og(~rm_p1);
[X_p2, rm_p2] = rmoutliers(X_og, "mean", "ThresholdFactor", 2);  X_labels_p2 = X_labels_og(~rm_p2);
[X_p3, rm_p3] = rmoutliers(X_og, "mean", "ThresholdFactor", 1.5);  X_labels_p3 = X_labels_og(~rm_p3);
[X_p4, rm_p4] = rmoutliers(X_og, "movmean", 30);  X_labels_p4 = X_labels_og(~rm_p4);


X_all = X(y,:);

%~~PART 3: RANDOM FOREST CLASSIFICATION AND CONFUSION MATRIX PLOT~~
progressbar('MainScript', root, 'Classification', 'RF Training & Accuracy Assessment', '')

progressbar(progress, 0.33, .3, 0, 0)
    [ogforest, ogforestCVClass, ogforestCVScore, ogforestCVErri, ogforestCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Original', 0); 
    [hopforest, hopforestCVClass, hopforestCVScore, hopforestCVErri, hopforestCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Hyperparameter Optimization', 0); 
    [pcaforest, pcaforestCVClass, pcaforestCVScore, pcaforestCVErri, pcaforestCVErr_dist] =...
        cellline_randomforest(X_pca, X_labels_og, pca_labels, 'PCA', 0); 
    [p1forest, p1forestCVClass, p1forestCVScore, p1forestCVErri, p1forestCVErr_dist] =...
        cellline_randomforest(X_p1, X_labels_p1, param_labels_og, 'Prune - 3 STD', 0);  
    [p2forest, p2forestCVClass, p2forestCVScore, p2forestCVErri, p2forestCVErr_dist] =...
        cellline_randomforest(X_p2, X_labels_p2, param_labels_og, 'Prune - 2 STD', 0); 
     [p3forest, p3forestCVClass, p3forestCVScore, p3forestCVErri, p3forestCVErr_dist] =...
        cellline_randomforest(X_p3, X_labels_p3, param_labels_og, 'Prune - 1_5 STD', 0); 
      [p4forest, p4forestCVClass, p4forestCVScore, p4forestCVErri, p4forestCVErr_dist] =...
        cellline_randomforest(X_p4, X_labels_p4, param_labels_og, 'Prune - 30W 3 STD', 0); 
    [op1forest, op1forestCVClass, op1forestCVScore, op1forestCVErri, op1forestCVErr_dist] =...
        cellline_randomforest(X_op1, X_labels_og, param_labels_opgnpg, 'Added Dist2Surf', 0); 
    
    

%~~PART 4: RANDOM FOREST ROC CURVE~~
progressbar('MainScript', root, 'Classification', 'ROC Assessment', '')
cellline_auc = cellline_roc(X_labels_p4, p4forestCVClass, p4forestCVScore, 'ROC ~ Prune 30W 3STD');

%~~PART 6A: SAVING FIGURES AS IMAGES~~
progressbar('MainScript', root, 'Classification', 'Saving Figures', '')
progressbar(progress, 0.33, .90, 0, 0) 
cd(figure_dir)
cellline_savefigures();

%~~PART 6B: EXPORT WORKSPACE~~
progressbar('MainScript', root, 'Classification', 'Exporting Workspace', '')
progressbar(progress, 0.33, .95, 0, 0) 
cd(save_dir)
save(workspace_filename);

a = 0
%~~FUNCTION DEFINITIONS~~
function [forest, forestCVClass, forestCVScore, forestCVErr_i, forestCVErr_dist] = cellline_randomforest(X, X_labels, param_labels, fig_title, skipconfusion)
    progressbar([], [], [], [], 0) 
    
    
    tic %tic and toc are statements that allow for time tracking
    rng('default');  %Setting the rng ensures reproducibility
    
    if contains(fig_title,'Hyperparameter Optimization')
        t = templateTree('Reproducible', true, 'Prune', 'off', 'PruneCriterion', 'error', 'SplitCriterion', 'gdi'); 
        forest = fitcensemble(X, X_labels, 'OptimizeHyperparameters', 'auto', 'Method', 'Bag', 'Learners', t,...
            'PredictorNames', param_labels); %Random Forest Algorithm 
    else
        t = templateTree('Reproducible', true, 'Prune', 'off', 'PruneCriterion', 'error', 'SplitCriterion', 'gdi'); 
        forest = fitcensemble(X, X_labels, 'Method', 'Bag', 'Learners', t,...
            'PredictorNames', param_labels); %Random Forest Algorithm
   
    end

    forestCV = crossval(forest); %10-Fold Cross Validation
    forestCVErr = kfoldLoss(forestCV); %Random Forest Algorithm Validation Error
    forestCVErr_i= kfoldLoss(forestCV, 'Mode', 'individual');
    [forestCVClass, forestCVScore] = kfoldPredict(forestCV); %Random Forest Algorithm Validation Prediction
    time = toc; %record the elapsed time
    forestCVErr_dist = [];

    for i = 1:10 % x10
        forestCV_alt = crossval(forest, 'KFold', 2); %2-Fold Cross Validation
        forestCVErr_dist = [forestCVErr_dist; kfoldLoss(forestCV_alt, 'Mode', 'individual')];
    end

    if skipconfusion == 0 %the confusion matrix could be skipped if desired
        figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.4 0.6]);
        
        cm = confusionchart(cellstr(X_labels), forestCVClass); %confusion matrix of validation data
        title([fig_title, newline, 'CV Accuracy: ', num2str(100-(forestCVErr*100)),... 
            '%', newline, append('Time: ', num2str(time), 'sec')])
        cm.FontName = 'Calibri';
        cm.FontSize = 15;
        cm.GridVisible = 'off';
        cm.DiagonalColor = "#266C26";
    end
end
function auc_data = cellline_roc(X_labels, forestCVClass, forestCVScore, fig_title)
    progressbar([], [], [], [], 0) 
    

    rocObj = rocmetrics(X_labels, forestCVScore, sort(unique(X_labels)));

    progressbar([], [], [], [], .5);
    figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.4 0.6]);
    rocplot = plot(rocObj, "AverageROCType","macro", "ShowModelOperatingPoint",false);
    title(fig_title, "FontName", "Calibri", "FontSize", 15)
    xlabel('False Positive Rate', "FontName", "Calibri", "FontSize", 15)
    ylabel('True Positive Rate', "FontName", "Calibri", "FontSize", 15)

    for i = 1:length(unique(X_labels))
        rocplot(i).LineWidth = 3;
        rocplot(i).Color =  '#c8e6c9';
    end

    rocplot(i+1).LineWidth = 4;
    rocplot(i+1).Color =  "#266C26";

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

        figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.8 0.6]); 
        barbar = bar(categorical(param_labels), imp);
        title(fig_title,"FontName", "Calibri", "FontSize", 15);
        ylabel('Estimates', "FontName", "Calibri", "FontSize", 15);
        xlabel('Predictors', "FontName", "Calibri", "FontSize", 15);
        barbar.FaceColor = "#266C26";
        barbar.EdgeAlpha = 0;
    end
end 

    function pvalues = cellline_ttest(combErr_dist, fig_title)
        figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.4 0.6]);
        box = boxplot((1 - combErr_dist), 'Notch', 'on', 'Labels', ...
            {'All', 'OPG', 'NPG', 'DPG', 'ONPG', 'ODPG', 'NDPG'}, ...
            'Colors', [.21 .59 .21]);
        yt = get(gca, 'YTick');
        axis([xlim    0  ceil(max(yt)*1.2)])
        xt = get(gca, 'XTick');
        hold on
        plot(xt([2 3]), [1 1]*max(yt)*1.1, '-k',  mean(xt([2 3])), max(yt)*1.15, '*k')
        hold off
        
  

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
        saveas(current_fig, [figure_filename adjusted_name], 'png') 
    end
end
end

