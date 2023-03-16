function RandomForest_11012021_AS(celllines_color, celllines, dir, root)
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
param_labels = imported.param_labels;
objectID = imported.objectID;
cell_list = imported.cell_list;

save_dir = [dir 'MATLAB Data'];
figure_dir = [dir 'Figures'];

figure_filename = [root '_Figure_'];
workspace_filename = [root '_Workspace.mat'];

%~~PART 2 - DEFINE PARAMETER SUBSETS~~
progressbar([], [], .05, 0, 0) 

%~~PART 3: RANDOM FOREST CLASSIFICATION AND CONFUSION MATRIX PLOT~~

figure('Name', 'Random Forest Classification', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.2 0 .6 1]);

progressbar([], [], .1, 0, 0)
subplot(3,3,1)
    cellline_algo(X, X_labels, param_labels, 'Random Forest', 0); 

%~~PART 6A: SAVING FIGURES AS IMAGES~~
progressbar([], [], .80, 0, 0) 
cd(figure_dir)
cellline_savefigures();

%~~PART 6B: EXPORT WORKSPACE~~
progressbar([], [], .82, 0, 0) 

cd(save_dir)
save(workspace_filename);

%~~FUNCTION DEFINITIONS~~
function cellline_algo(X, X_labels, param_labels, fig_title, skipconfusion)
    progressbar([], [], [], 0) 
    tic %tic and toc are statements that allow for time tracking
    rng('default');  %Setting the rng ensures reproducibility
    progressbar([], [], [], .3) 
    
    if strcmp(fig_title, 'Random Forest')
        t = templateTree('Reproducible', true, 'Prune', 'off', 'PruneCriterion', 'error', 'SplitCriterion', 'gdi'); 
        forest = fitcensemble(X, X_labels, 'Method', 'Bag', 'Learners', t,...
            'PredictorNames', param_labels); %Random Forest Algorithm
        forestCV = crossval(forest); %10-Fold Cross Validation
        forestCVErr = kfoldLoss(forestCV); %Random Forest Algorithm Validation Error
        forestCVErr_i= kfoldLoss(forestCV, 'Mode', 'individual');
        [forestCVClass, forestCVScore] = kfoldPredict(forestCV); %Random Forest Algorithm Validation Prediction
    elseif
    end
    
    time = toc; %record the elapsed time
    progressbar([], [], [], .6) 
    if skipconfusion == 0 %the confusion matrix could be skipped if desired
        cm = confusionchart(cellstr(X_labels), forestCVClass); %confusion matrix of validation data
        title([fig_title, newline, 'Cross-Validation Accuracy: ', num2str(100-(forestCVErr*100)),... 
            '%', newline, 'Elapsed Time: ', num2str(time), 's'])
        cm.FontName = 'Arial';
        cm.FontSize = 12;
        cm.GridVisible = 'off';
        
    end
end
    
    t = tiledlayout('flow','TileSpacing','compact');
    nexttile
    hold on
    
    auc_data = [];
    for i = 1:length(celllines)
        progressbar([], [], [], (i-1)/length(celllines)) 
        negscore = forestCVScore; negscore(:,i) = [];
        diffscore = forestCVScore(:,i) - max(negscore, [], 2);
        [roc_x, roc_y, ~, auc] = perfcurve(X_labels, diffscore, celllines(i));
        plot(roc_x, roc_y, 'linewidth', 2, 'LineStyle','--')
        legends{i} = sprintf('%s (%.5f)', celllines(i), auc);
        auc_data = [auc_data; auc];
    end
    
    lgd = legend(legends, 'location', 'southeast');
    lgd.Layout.Tile = 'east';
    lgd.FontSize = 12;
    title(lgd, "Celllines (area under ROC)")
    line([0 1], [0 1], 'linestyle', '-.', 'color', 'k');
    xlabel('100% - Specificity%'), ylabel('Sensitivity%')
    title(fig_title, 'FontSize', 14)
    axis square
                                                                                                                                                                                                                                                                                                                                    
end

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
        progressbar([], [], [], (i-1)/length(allfigures))
        current_fig = allfigures(i);
        
        %the 'Name' of the figure correlates to the naming at the top of
        %the window
        fig_name = current_fig.Name;
        
        %Note that we do not want to save progress bars. These have no
        %title, so these can be accounted for by the statement below
        if strcmp(fig_name, '')
            continue;
        end
        
        %We use the title of the figure to alter the filename of the figure
        %once saved
        adjusted_name = strrep(fig_name,'~', '_');
        adjusted_name = strrep(adjusted_name ,' ', '');
        
        %Save the figure as a .m file and 
        saveas(current_fig, [figure_filename adjusted_name], 'm') 
        saveas(current_fig, [figure_filename adjusted_name], 'png') 
    end
end
end

