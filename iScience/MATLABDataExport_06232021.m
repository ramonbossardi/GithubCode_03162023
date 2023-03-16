function MATLABDataExport_06232021(dir, root)

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
progressbar([], [], .2, 0, 0)
cellline_completedataexport(M.X_opg, M.X_labels, M.param_labels_opg, M.objectID, M.celllines, ...
    M.forestCVErri_opg, M.imp_opg, M.forestCVScore_opg, M.cellline_auc_opg , [root '_OPG']);
progressbar([], [], .3, 0, 0)
cellline_completedataexport(M.X_npg, M.X_labels, M.param_labels_npg, M.objectID, M.celllines, ...
    M.forestCVErri_npg, M.imp_npg, M.forestCVScore_npg, M.cellline_auc_npg , [root '_NPG']);
progressbar([], [], .4, 0, 0)
cellline_completedataexport(M.X_dpg, M.X_labels, M.param_labels_dpg, M.objectID, M.celllines, ...
    M.forestCVErri_dpg, M.imp_dpg, M.forestCVScore_dpg, M.cellline_auc_dpg , [root '_DPG']);
progressbar([], [], .5, 0, 0)
cellline_completedataexport(M.X_opgnpg, M.X_labels, M.param_labels_opgnpg, M.objectID, M.celllines, ...
    M.forestCVErri_opgnpg, M.imp_opgnpg, M.forestCVScore_opgnpg, M.cellline_auc_opgnpg , [root '_OPGNPG']);
progressbar([], [], .6, 0, 0)
cellline_completedataexport(M.X_opgdpg, M.X_labels, M.param_labels_opgdpg, M.objectID, M.celllines, ...
    M.forestCVErri_opgdpg, M.imp_opgdpg, M.forestCVScore_opgdpg, M.cellline_auc_opgdpg , [root '_OPGDPG']);
progressbar([], [], .7, 0, 0)
cellline_completedataexport(M.X_npgdpg, M.X_labels, M.param_labels_npgdpg, M.objectID, M.celllines, ...
    M.forestCVErri_npgdpg, M.imp_npgdpg, M.forestCVScore_npgdpg, M.cellline_auc_npgdpg , [root '_NPGDPG']);

progressbar([], [], .8, 0, 0)
cellline_dpgexport(M.X, M.X_labels, M.dpg_data, M.celllines, [root '_Full_DPGData']);

progressbar([], [], .9, 0, 0)
cellline_altdataexport(M.X, M.X_labels, M.objectID, M.param_labels, M.dpg_data, M.celllines, M.cell_list, [root '_Full_Alt']);
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

function cellline_altdataexport(X, X_labels, objectID, param_labels, dpg_data, celllines, cell_list, filename)
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

    %Slide 3 - Mean Per Cell and Parameter
    progressbar([], [], [], 2/8, 0)
    [X_labels_mean, X_mean] = cellline_meancelldata(X, X_labels, dpg_data);
    cellnum = length(X_labels_mean)/length(celllines);
    for i = 1:length(param_labels)
        progressbar([], [], [], [], (i-1)/length(param_labels))
        start = 1;
        reorg_meandata = [];
        for j = 1:length(celllines)
            reorg_meandata = [reorg_meandata X_mean(start:(start+cellnum-1),i)];
            start = start + cellnum;
        end
        
        A2 = cell2table([cellstr(cell_list.') num2cell(reorg_meandata)]);
        A2.Properties.VariableNames = cellstr([' ' celllines]);
        writetable(A2, strcat(param_labels_sheetname(i), 'Data.csv'))
    end
    
    %Sum Per Cell (Volume and Area)
    progressbar([], [], [], 3/8, 0)
    [X_labels_sum, X_sum] = cellline_sumcelldata(X, X_labels, dpg_data);
    area_idx = contains(param_labels, 'Area');
    volume_idx = contains(param_labels, 'Volume');
    start = 1;
    reorg_sumdata = [];
    for j = 1:length(celllines)
         progressbar([], [], [], [], (j-1)/length(celllines))
         reorg_sumdata = [reorg_sumdata X_sum(start:(start+cellnum-1), volume_idx)];
         start = start + cellnum;
    end
    A3 = cell2table([cellstr(cell_list.') num2cell(reorg_sumdata)]);
    A3.Properties.VariableNames = cellstr([' ' celllines]);
    writetable(A3, 'VolumeSumData.csv')
    
    progressbar([], [], [], 4/8, 0)
    start = 1;
    reorg_sumdata = [];
    for j = 1:length(celllines)
         progressbar([], [], [], [], (j-1)/length(celllines))
         reorg_sumdata = [reorg_sumdata X_sum(start:(start+cellnum-1), area_idx)];
         start = start + cellnum;
    end
    A4 = cell2table([cellstr(cell_list.') num2cell(reorg_sumdata)]);
    A4.Properties.VariableNames = cellstr([' ' celllines]);
    writetable(A4, 'AreaSumData.csv')

    %Slide 4 - Normalized Mean Data
    progressbar([], [], [], 5/8, 0)
    meansheet_data = [];
    start = 1;
    for i = 1:length(celllines)
        progressbar([], [], [], [], i/length(celllines))
        norm_data = normalize(X_mean,'range');
        norm_data = norm_data(start:(start+cellnum-1),:).';
        
        A5 = cell2table([cellstr(param_labels.') num2cell(norm_data) num2cell(mean(norm_data, 2))]);
        A5.Properties.VariableNames = cellstr([' ' X_labels_mean(1:cellnum).' 'Average']);
        writetable(A5,  strcat('Norm', celllines(i), 'Data.csv'))
        
        meansheet_data = [meansheet_data mean(norm_data,2)];
        start = start + cellnum;
    end
    A5 = cell2table([cellstr(param_labels.') num2cell(meansheet_data)]);
    A5.Properties.VariableNames = cellstr(["Parameters" celllines]);
    writetable(A5,  strcat('NormMeanData.csv'))
    
    %Slide 5 - LN of Data
    progressbar([], [], [], 6/8, 0)
    for i = 1:length(celllines)
        progressbar([], [], [], [], (i-1)/length(celllines))
        cl_range = contains(X_labels, celllines(i));
        
        A6 = cell2table([cellstr(X_labels(cl_range)) num2cell(objectID(cl_range)) num2cell(log(X(cl_range,:)))]);
        A6.Properties.VariableNames = cellstr([" " 'Object ID #' param_labels]);
        writetable(A6,  strcat('ln', celllines(i), 'Data.csv'))
    end

    %Slide 6 - Number of Objects Per Cell
    progressbar([], [], [], 7/8, 0)
    numobj_data = zeros(cellnum, length(celllines));
    for i = 1:length(dpg_data)
        progressbar([], [], [], [], (i-1)/length(dpg_data))
        celllength = length(cell2mat(dpg_data(i)));
        numobj_data((mod(i-1, cellnum)+1), floor((i-1)/cellnum) + 1) = celllength;
    end
    A7 = cell2table([cellstr(X_labels_mean(1:cellnum)) num2cell(numobj_data)]);
    A7.Properties.VariableNames = cellstr([' ' celllines]);
    writetable(A7,  'NumofObjects.csv')
    
    cd ../
end
function cellline_dpgexport(X, X_labels, dpg_data, celllines, filename)
    cellnum = length(dpg_data)/length(celllines);
    progressbar([], [], [], 'DPG Data')
    
    mkdir(filename)
    cd(filename)
    
    %Slide 7: DPG Per Cell
    progressbar([], [], [], .2)
    dpg_data1 = cell(1,length(dpg_data));
    for i = 1:length(dpg_data)
        progressbar([], [], [], [], (i-1)/length(dpg_data))
        current_dpg_data = cell2mat(dpg_data(i));
        dpg_reshaped = nonzeros(reshape(current_dpg_data, [], 1));
        dpg_data1(1,i) = {dpg_reshaped};
    end   
    %{
    [X_labels_mean, ~] = cellline_meancelldata(X, X_labels, dpg_data);
    start = 1;
    dpgcell = {};
    for j = 1:length(celllines)
        current_celline_data = dpg_data1(start:(start+cellnum-1));
        dpgdata_cell = {};
        label_cell = {};
        for i = 1:length(current_celline_data)
            current_col = cell2mat(current_celline_data(i));
            k = 1;
            while length(current_col) > (k)
                dpgdata_cell = [dpgdata_cell cell(1000000,1)];
                if k == 1
                    label_cell = [label_cell cellstr(X_labels_mean(i))];
                else
                    label_cell = [label_cell cellstr(' ')];
                end
                dpgdata_cell(1:min([length(current_col), k + 999999]), end) = num2cell(current_col);
                k = k + 1000000;
            end
        end  
        start = start + cellnum;
        D1 = cell2table(dpgdata_cell);
        D1.Properties.VariableNames = cellstr(label_cell);
        writetable(D1, strcat(celllines(j), 'Data Per Cell.csv'))
    end
    %}
    
    progressbar([], [], [], .4, 0)
    dpg_data2 = cell(1, length(celllines));
    start = 1;
    for j = 1:length(celllines)
        progressbar([], [], [], [], (j-1)/length(celllines))
        temp_datacolumn = [];
        for i = start:(start+cellnum-1)
            current_cellline_data = cell2mat(dpg_data1(i));
            temp_datacolumn = [temp_datacolumn; current_cellline_data];
        end
        dpg_data2(1, j) = {temp_datacolumn};
        start = start + cellnum;
    end
    
    %Exports Binned DPG Data
    progressbar([], [], [], .6, 0)
    bins = 0:2:60;
    bindata_cell = num2cell(bins(2:end).');
    percentbindata_cell = num2cell(bins(2:end).');
    for i = 1:length(dpg_data2)
        progressbar([], [], [], [], (i-1)/length(dpg_data2))
        
        current_col = cell2mat(dpg_data2(i));
        bin_col = histcounts(current_col, bins);
        bindata_cell = [bindata_cell num2cell(bin_col.')];
        percentbindata_cell = [percentbindata_cell num2cell(((bin_col/sum(bin_col)) * 100).')];
    end
    bindata_cell = [bindata_cell cell(length(bindata_cell),1) percentbindata_cell];
    
    D2 = cell2table(bindata_cell);
    D2.Properties.VariableNames = cellstr(['Bins' celllines " " 'Bins ' strcat(celllines, ' (%)')]);
    writetable(D2, 'BinnedDPGData.csv')
    
    cd ../
end

function [X_labels_meancell, X_meancell] = cellline_meancelldata(X, X_labels, dpg_data)
    X_labels_meancell = [];
    X_meancell = [];

    counter = 1;
    celltype = '';
    for i = 1:length(dpg_data)
         if (~strcmp(celltype, X_labels(counter)))
            cellnum = 1;
            accountforerror = 0;
         else
            cellnum = cellnum + 1;
         end

         celltype = X_labels(counter);
         celllength = length(cell2mat(dpg_data(i)));
         mean_range = counter : counter + celllength - 1;

         if cellnum == 2
             X_labels_meancell = [X_labels_meancell; strcat('Cell 10')];
             accountforerror = 1;
         elseif accountforerror == 1
             X_labels_meancell = [X_labels_meancell; strcat('Cell ', string(cellnum-1))];
         else
             X_labels_meancell = [X_labels_meancell; strcat('Cell ', string(cellnum))];
         end

         X_meancell = [X_meancell; mean(X(mean_range,:))];


         counter = counter + celllength;
    end
end
function [X_labels_sumcell, X_sumcell] = cellline_sumcelldata(X, X_labels, dpg_data)
    X_labels_sumcell = [];
    X_sumcell = [];

    counter = 1;
    celltype = '';
    for i = 1:length(dpg_data)
         if (~strcmp(celltype, X_labels(counter)))
            cellnum = 1;
            accountforerror = 0;
         else
            cellnum = cellnum + 1;
         end

         celltype = X_labels(counter);
         celllength = length(cell2mat(dpg_data(i)));
         sum_range = counter : counter + celllength - 1;

         if cellnum == 2
             X_labels_sumcell = [X_labels_sumcell; strcat('Cell 10')];
             accountforerror = 1;
         elseif accountforerror == 1
             X_labels_sumcell = [X_labels_sumcell; strcat('Cell ', string(cellnum-1))];
         else
             X_labels_sumcell = [X_labels_sumcell; strcat('Cell ', string(cellnum))];
         end

         X_sumcell = [X_sumcell; sum(X(sum_range,:))];


         counter = counter + celllength;
    end
end