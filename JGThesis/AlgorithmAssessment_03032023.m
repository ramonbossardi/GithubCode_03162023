function AlgorithmAssessment_03032023(celllines_color, celllines, dir, root, progress)
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




%~~PART 3: RANDOM FOREST CLASSIFICATION AND CONFUSION MATRIX PLOT~~
progressbar('MainScript', root, 'Classification', 'RF Training & Accuracy Assessment', '')
progressbar(progress, 0.33, .3, 0, 0)
    [forest, forestCVClass, forestCVScore, forestCVErri, forestCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Random Forest', 0); 
    [qsvm, qsvmClass, qsvmCVScore, qsvmCVErri, qsvmCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Quad SVM', 0);
    [csvm, csvmClass, csvmCVScore, csvmCVErri, csvmCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Cubic SVM', 0);
    [mgsvm, mgsvmClass, mgsvmCVScore, mgsvmCVErri, mgsvmCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Med Gaussian SVM', 0);
    [nnn, nnnClass, nnnCVScore, nnnCVErri, nnnCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Narrow NN', 0);
    [mnn, mnnClass, mnnCVScore, mnnCVErri, mnnCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Med NN', 0);
    [wnn, wnnClass, wnnCVScore, wnnCVErri, wnnCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Wide NN', 0);
    [bnn, bnnClass, bnnCVScore, bnnCVErri, bnnCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Bilayer NN', 0);
    [tnn, tnnClass, tnnCVScore, tnnCVErri, tnnCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Trilayer NN', 0);
    [tree, treeClass, treeCVScore, treeCVErri, treeCVErr_dist] =...
        cellline_randomforest(X_og, X_labels_og, param_labels_og, 'Fine Tree', 0);

%~~PART 4: RANDOM FOREST ROC CURVE~~
progressbar('MainScript', root, 'Classification', 'ROC Assessment', '')
   

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
    
    if contains(fig_title,'Random Forest')
        t = templateTree('Reproducible', true, 'Prune', 'off', 'PruneCriterion', 'error', 'SplitCriterion', 'gdi'); 
        forest = fitcensemble(X, X_labels, 'Method', 'Bag', 'Learners', t,...
            'PredictorNames', param_labels); %Random Forest Algorithm
    elseif contains(fig_title,'Quad SVM')
        t = templateSVM('KernelFunction','polynomial', 'PolynomialOrder', 2, 'KernelScale','auto', 'BoxConstraint', 1, 'Standardize',true);
        forest = fitcecoc(X, X_labels, 'PredictorNames', param_labels, 'Learners', t, 'Coding','onevsone');
    elseif contains(fig_title,'Cubic SVM')
         t = templateSVM('KernelFunction','polynomial', 'PolynomialOrder', 3, 'KernelScale','auto', 'BoxConstraint', 1, 'Standardize',true);
        forest = fitcecoc(X, X_labels, 'PredictorNames', param_labels, 'Learners', t, 'Coding','onevsone');
    elseif contains(fig_title,'Med Gaussian SVM')
        t = templateSVM('KernelFunction','gaussian', 'KernelScale', 4.6, 'BoxConstraint', 1, 'Standardize',true);
        forest = fitcecoc(X, X_labels, 'PredictorNames', param_labels, 'Learners', t, 'Coding','onevsone');
    elseif contains(fig_title,'Narrow NN')
        forest = fitcnet(X, X_labels, 'LayerSizes', 10, 'PredictorNames', param_labels, 'Lambda', 0, 'Activations','relu', 'Standardize',true);
    elseif contains(fig_title,'Med NN')
        forest = fitcnet(X, X_labels, 'LayerSizes', 25, 'PredictorNames', param_labels, 'Lambda', 0, 'Activations','relu', 'Standardize',true);
    elseif contains(fig_title,'Wide NN')
        forest = fitcnet(X, X_labels, 'LayerSizes', 100, 'PredictorNames', param_labels, 'Lambda', 0, 'Activations','relu', 'Standardize',true);
    elseif contains(fig_title,'Bilayer NN')
        forest = fitcnet(X, X_labels, 'LayerSizes', [10 10], 'PredictorNames', param_labels, 'Lambda', 0, 'Activations','relu', 'Standardize',true);
    elseif contains(fig_title,'Trilayer NN')
        forest = fitcnet(X, X_labels, 'LayerSizes', [10 10 10], 'PredictorNames', param_labels, 'Lambda', 0, 'Activations','relu', 'Standardize',true);
    elseif contains(fig_title,'Fine Tree')
        forest = fitctree(X, X_labels, 'MaxNumSplits', 100);
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
    

    rocObj = rocmetrics(X_labels, forestCVScore, sort(celllines));

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

