function IMARISDataImport_02202023_Track(celllines_color, celllines, maindir, root, type, tp, pool, progress)
    comp = ["Area", "BoundingBoxAA", 'BoundingBoxOO', 'Distance from Origin Ref',...
      'Ellipticity (oblate)', 'Ellipticity (prolate)', 'Number of Triangles', 'Number of Voxels', ...
      'Position Reference Frame', 'Shortest Distance to Surfac', 'Sphericity', 'Volume' ]; 
    param_labels = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X',...
      'BB OO Y', 'BB OO Z', 'Dist Origin', 'Oblate','Prolate',...
      'Triangles', 'Voxels', 'Position X', 'Position Y', 'Position Z', 'Dist Surface',...
      'Sphericity', 'Volume', 'CI', 'BI AA', 'BI OO', 'Polarity']; %Note: this variable gets added to and reordered
    warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
    
  
    
    %Implement a dialog box for this part later on
    import_dir = [maindir 'IMARIS Data'];
    save_dir = [maindir 'MATLAB Data'];
    save_filename = [root '_ImportedIMARISData.mat'];

    %~~PART 1: PRIMARY PARAMETER IMPORTATION~~
    progressbar('MainScript', root, 'Importing', 'Parameter Import', '')
    progressbar(progress, 0, 0, 0, 0)
    [X, X_labels, T_labels, objectID, cell_list, cellX_labels] = parameter_import(import_dir);
    

    %~~PART 2: SECONDARY PARAMETER CALCULATION~~
    progressbar('MainScript', root, 'Importing', 'Parameter Calculation', '')
    progressbar(progress, 0, .4, 0, 0)
    [X, dpg_data] = parameter_calc(X, T_labels, objectID, cell_list, cellX_labels);
    
    
    %~~PART 3: REORDER PARAMETERS ALPHABETICALLY~~\
    progressbar('MainScript', root, 'Importing', 'Reorganization and Saving', '')
    progressbar(progress, 0, .8, 0, 0)
    [param_labels, sort_idx] = sort(param_labels);
    X = X(:,sort_idx);

    progressbar(progress, 0, .85, 0, 0)

    %~~PART 4: MAT FILE EXPORTATION
    cd(save_dir)
    save(save_filename)
    cd ../

    %~~FUNCTION DEFINITIONS~~
    function [X, X_labels, T_labels, objectID, cell_list, cellX_labels] = parameter_import(location)
            %Loading Bar
            progressbar([], [], [], 0, 0) 
            dir(location)

            %ds0 = spreadsheetDatastore(location, 'Range', 'B5:B6', 'Sheets', {'Overall'});
            %num_objects = sum(table2array((readall(ds0))));
            ds1 = spreadsheetDatastore(location);
            files = ds1.Files;
            
            %{
            modifiedfiles = erase(files, location);
            %Determine which cell line the data is for based on the filename
            celllines_temp = erase(erase(celllines, "WT"), "KO");
            for c = 1:length(modifiedfiles)    
                if contains(modifiedfiles(c), "wt")
                    modifiedfiles(c) = replace(modifiedfiles(c), celllines_temp, strcat(celllines_temp, 'WT'));
                elseif contains(modifiedfiles(c), "ko")
                    modifiedfiles(c) = replace(modifiedfiles(c), celllines_temp, strcat(celllines_temp, 'KO'));
                end
            end
            [modifiedfiles, modfile_i] = sort(modifiedfiles);
            files = files(modfile_i)
            %}

            %data array allocation
            X = [];
            X_labels = [];
            T_labels = [];
            objectID = [];
            cell_list = [];
            cellX_labels = [];

            errorfile_list = [];

            for i = 1:length(files) %for every excel file
                active_file = files(i); %current Excel filepath
                full_sheets = string(sheetnames(ds1, i)); %The list of sheet names for the file

                if contains(type, "Track")
                        param_labels = ["Ar1", "Area", "Displacement X", "Displacement Y", "Displacement Z",...
                              "Ellipticity Oblate", "Ellipticity Prolate", "Track Length", "Number of Triangles", ...
                              "Number of Voxels", 'Mean Position X', 'Mean Position Y','Mean Position Z',...
                              'Start Position X', 'Start Position Y', 'Start Position Z', ...
                              "Speed", "Sphericity", "Track Straightness" ...
                              "Volume", 'BoundingBox AA X', 'BoundingBox AA Y', 'BoundingBox AA Z', ...
                              "BoundingBox OO X", "BoundingBox OO Y", "BoundingBox OO Z",...
                              "Acceleration X", "Acceleration Y", "Acceleration Z" ...
                              'Velocity X', 'Velocity Y', 'Velocity Z',...
                              'Distance to Nuc Surface', 'CI', 'BI AA', 'BI OO', 'Polarity']; %Note: this variable gets added to and reordered

                        %these are already averaged per Track
                         mean_comp = ["Track Ar1 Mean Reference Frame", "Track Area Mean Referen", "Track Displacement Referen",...
                              "Track Ellipticity Oblate Mean", "Track Ellipticity Prolate Mean", "Track Length Reference Frame", "Track Number of Triangles R", ...
                              "Track Number of Voxels", 'Track Position Reference Frame', 'Track Position Start Ref', ...
                              "Track Speed Mean", "Track Sphericity Mean Refer", "Track Straightness" ...
                              "Track Volume Mean Reference"];

                         %these aren't and need to be averaged
                         nonmean_comp = ['BoundingBoxAA Length', "BoundingBoxOO Length", "Acceleration Vector Refer", 'Velocity Reference Frame', 'Shortest Distance'];

                        % I - Import Averaged Track Data
                        sheets_index = find(contains(full_sheets, mean_comp)); %limit the importation to only the relevant sheets
                        for d = 1:length(mean_comp)
                            if ~contains(full_sheets, mean_comp(d))
                                disp(append('Parameter Sheet ', mean_comp(d) , ' undetected in file ', cellnum_filename, '. Check the code and/or file for errors.'))
                            end
                        end

                        X_temp = [];
                        debu_labels = [];
                        progressbar([], [], [], (i-1)/length(files), 0)

                        for k = 1:length(sheets_index) %for every relevant sheet in the excel file
                        var = sheets_index(k); %current sheet index
                        active_sheet = full_sheets(var); %current sheet name
    
                        %Update waitbar
                        progressbar([], [], [], [], (k-1)/length(sheets_index))                        
                        %3 Parameter Imports
                        if contains(active_sheet, 'Track Position') || contains(active_sheet, "Track Displacement Referen")
                            imported_table = readtable(string(active_file), 'Range', 'A:C', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = table2array(imported_table);
                            X_temp = [X_temp temp];
                            debu_labels = [debu_labels; append(active_sheet, "X"); append(active_sheet, "Y"); append(active_sheet, "Z")];
    
                        else
                            imported_table = readtable(string(active_file), 'Range', 'A:A', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = table2array(imported_table);

                            %if (length(X_temp) ~= length(temp)) && (length(X_temp) ~= 0)
                                %error = 'error';
                            %end

                            X_temp = [X_temp temp];
                            debu_labels = [debu_labels; active_sheet];
                            
                            file_length = length(temp); %record number of objects for reference

                            %imports track IDs
                            imported_table = readtable(string(active_file), 'Range', 'E:E', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            cellobjectID = table2array(imported_table);
                        end
                        end

                        % II - Import and Average Non-Mean Data
                        sheets_index = find(contains(full_sheets, nonmean_comp)); %limit the importation to only the relevant sheets
                        for d = 1:length(nonmean_comp)
                            if ~contains(full_sheets, nonmean_comp(d))
                                disp(append('Parameter Sheet ', nonmean_comp(d) , ' undetected in file ', cellnum_filename, '. Check the code and/or file for errors.'))
                            end
                        end
        
                        nmX_temp = [];
                        progressbar([], [], [], (i-1)/length(files), 0)
                        dapi_import = 0;
                        
                        for k = 1:length(sheets_index) %for every relevant sheet in the excel file
                        var = sheets_index(k); %current sheet index
                        active_sheet = full_sheets(var); %current sheet name
    
                        %Update waitbar
                        progressbar([], [], [], [], (k-1)/length(sheets_index)) 

                        %Distance to Nucleus Surface: Limit to Sheet with Appropiate Cell DAPI Data.
                        if contains(active_sheet, 'Shortest Distance') && ~contains(active_sheet, 'Track') 
                            %Import the column indicating the data type
                            imported_table = readtable(string(active_file), 'Range', 'D:D', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            surfdist_IDdata = table2array(imported_table);
    
                            %determine correct cell number
                            match = wildcardPattern + "\";
                            cellnum_filename = erase(active_file, match);
                            cellnum_str = regexp(cellnum_filename, 'cell\d*', 'match');
                            cellnum = sscanf(string(cellnum_str), 'cell%f');
    
                            %Determine if appropiate DAPI (is presented in different ways)
                            surfdist_string = [strcat("cell", string(cellnum), " DAPI"), strcat("dapi cell", string(cellnum)), ...
                                strcat("DAPI ", string(cellnum)), strcat("cell", string(cellnum), " nuc"), ...
                                strcat("cell", string(cellnum), " ko nuc"), strcat("cell", string(cellnum), " wt nuc"), ...
                                strcat("cell ", string(cellnum), " nuc"), strcat("cell ", string(cellnum), " ko nuc"), ...
                                strcat("cell ", string(cellnum), " wt nuc"), "NUCS"];
    
                            %Import appropiate data
                            if (contains(surfdist_IDdata(end), surfdist_string,'IgnoreCase',true)) && (dapi_import == 0)
                                %import 1 column for Distance to Surface
                                imported_table = readtable(string(active_file), 'Range', 'A:A', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                                temp = table2array(imported_table);
                                nmX_temp = [nmX_temp temp];
                                debu_labels = [debu_labels; "Dist2Surf"];
                                dapi_import = 1;
                            end
    
                        else
                            %import 3 columns for every other primary component
                            imported_table = readtable(string(active_file), 'Range', 'A:C', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = table2array(imported_table);

                            %if (length(X_temp) ~= length(temp)) && (length(X_temp) ~= 0)
                               % error = 'error';
                           % end
                            nmX_temp = [nmX_temp temp];
                            debu_labels = [debu_labels; active_sheet];
                            
                            if contains(active_sheet, 'BoundingBox')
                                imported_table = readtable(string(active_file), 'Range', 'H:H', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                                nm_cellobjectID =table2array(imported_table);
                            else
                                imported_table = readtable(string(active_file), 'Range', 'I:I', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                                nm_cellobjectID =table2array(imported_table);
                            end
                        end
                        end
                        
                        fixednmX_temp = [];
                        for w = 1:length(cellobjectID)
                            current_trackID = cellobjectID(w);
                            
                            current_trackidx = nm_cellobjectID == current_trackID;
                            current_track_nmX = nmX_temp(current_trackidx, :);

                            fixednmX_temp = [fixednmX_temp; mean(current_track_nmX)];
                        end

                        X_temp = [X_temp fixednmX_temp];
                        X = [X; X_temp]; %add data to X
                        objectID = [objectID; cellobjectID]; %add objectID data

                        %Determine which cell line the data is for based on the filename
                        for c = 1:length(celllines)
                            if contains(active_file, celllines(c))
                                cellline_name = celllines(c);
                                
                            end
                        end
        
        
                        %Add label to X_labels
                        X_labels_temp = string(zeros(file_length, 1));
                        X_labels_temp(1:file_length, 1) = cellline_name;
                        X_labels = [X_labels; X_labels_temp]; %#ok<*AGROW>
                        cell_list = [cell_list; append(cellline_name, ' ', string(cellnum_str))];
                        cellX_labels = [cellX_labels; append(X_labels_temp, ' ', string(cellnum_str))];
               
                        

                else
                    sheets_index = find(contains(full_sheets, comp)); %limit the importation to only the relevant sheets
                    for d = 1:length(comp)
                        if ~contains(full_sheets, comp(d))
                            disp(append('Parameter Sheet ', comp(d) , ' undetected in file ', cellnum_filename, '. Check the code and/or file for errors.'))
                        end
                    end
    
                    X_temp = [];
                    debu_labels = [];
                    progressbar([], [], [], (i-1)/length(files), 0)
                    dapi_import = 0;
                    
    
                    for k = 1:length(sheets_index) %for every relevant sheet in the excel file
                        var = sheets_index(k); %current sheet index
                        active_sheet = full_sheets(var); %current sheet name
    
                        %Update waitbar
                        progressbar([], [], [], [], (k-1)/length(sheets_index)) 
    
                        %~~SPECIAL CASES~~
                        if contains(active_sheet, "Track")
                            continue
                        %Bounding Box: 3 Parameters
                        elseif contains(active_sheet, "BoundingBox")
                            imported_table = readtable(string(active_file), 'Range', 'A:C', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = table2array(imported_table);
                            X_temp = [X_temp temp];
                            debu_labels = [debu_labels; "BBX"; "BBY"; "BBZ"];
    
                            imported_table = readtable(string(active_file), 'Range', 'A2:Z2', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = imported_table.Properties.VariableNames;
                            time_col = find(contains(string(temp), 'Time'));
                            time_col = char(64 + time_col);
                            if time_col == ""
                                continue
                            end
                            imported_table = readtable(string(active_file), 'Range', strcat(time_col, ":", time_col), 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            
                            if contains(type, "Live")
                                T_labels_temp = table2array(imported_table);
                            end
    
                        %Distance from Origin + Position: Reference Different Cell Nucleui.
                        %only import data that references the correct cell number
                        elseif contains(active_sheet, 'Distance from Origin') || contains(active_sheet, 'Position')
                            %Adjust reference indicator column location
                            if contains(active_sheet, 'Distance from Origin') %Distance from Origin
                                imported_table = readtable(string(active_file), 'Range', 'E:E', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            else  %Position
                                imported_table = readtable(string(active_file), 'Range', 'G:G', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            end
                            cellnum_data = table2array(imported_table(2:end,:)); %contains the reference numbers the data
    
                            %IF SOMETHING IS WRONG WITH ALL REFERENCE PARAMETERS,
                            %CHECK HERE IF THE FILE NAME CHANGED
    
                            %This code assumes the file name is "(cellline) cell#  ........."
    
                            match = wildcardPattern + "\";
                            cellnum_filename = erase(active_file, match);
                            cellnum_str = regexp(cellnum_filename, 'cell\d*', 'match');
                            cellnum = sscanf(string(cellnum_str), 'cell%f');
                          
                            
                            cellnum_index = contains(cellnum_data, string(cellnum)); %select only data indices with matching cell number
                            if sum(cellnum_index) == 0
                                cellnum_index(:) = 1;
                            end
                            
                            if contains(active_sheet, 'Distance') %Distance from Origin
                                %import 1 column for Distance data
                                imported_table = readtable(string(active_file), 'Range', 'A:A', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                                temp = table2array(imported_table);
                                
                                X_temp = [X_temp temp(cellnum_index)];
                                debu_labels = [debu_labels; "Dist2Origin"];
                            else  %Position
                                %import 3 columns for Position data
                                imported_table = readtable(string(active_file), 'Range', 'A:C', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                                temp = table2array(imported_table);
    
                                X_temp = [X_temp temp(cellnum_index,:)];
                                debu_labels = [debu_labels; "PosX"; "PosY"; "PosZ"];
                            end
    
                        %Distance to Nucleus Surface: Limit to Sheet with Appropiate Cell DAPI Data.
                        elseif contains(active_sheet, 'Shortest Distance')
                            %Import the column indicating the data type
                            imported_table = readtable(string(active_file), 'Range', 'D:D', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            surfdist_IDdata = table2array(imported_table);
    
                            %determine correct cell number
                            match = wildcardPattern + "\";
                            cellnum_filename = erase(active_file, match);
                            cellnum_str = regexp(cellnum_filename, 'cell\d*', 'match');
                            cellnum = sscanf(string(cellnum_str), 'cell%f');
    
                            %Determine if appropiate DAPI (is presented in different ways)
                            surfdist_string = [strcat("cell", string(cellnum), " DAPI"), strcat("dapi cell", string(cellnum)), ...
                                strcat("DAPI ", string(cellnum)), strcat("cell", string(cellnum), " nuc"), ...
                                strcat("cell", string(cellnum), " ko nuc"), strcat("cell", string(cellnum), " wt nuc"), ...
                                strcat("cell ", string(cellnum), " nuc"), strcat("cell ", string(cellnum), " ko nuc"), ...
                                strcat("cell ", string(cellnum), " wt nuc"), "NUCS"];
    
                            %Import appropiate data
                            if (contains(surfdist_IDdata(end), surfdist_string,'IgnoreCase',true)) && (dapi_import == 0)
                                %import 1 column for Distance to Surface
                                imported_table = readtable(string(active_file), 'Range', 'A:A', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                                temp = table2array(imported_table);
                                X_temp = [X_temp temp];
                                debu_labels = [debu_labels; "Dist2Surf"];
                                dapi_import = 1;
                            end
    
                        %~~DEFAULT IMPORTATION~~
                        else
                            %import 1 column for every other primary component
                            imported_table = readtable(string(active_file), 'Range', 'A:A', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = table2array(imported_table);
                            if (length(X_temp) ~= length(temp)) && (length(X_temp) ~= 0)
                                error = 'error';
                            end
                            X_temp = [X_temp temp];
                            debu_labels = [debu_labels; active_sheet];
                            
                            file_length = length(temp); %record number of objects for reference
                            cellobjectID = (0:(file_length-1)).'; %Stores cellobjectID
                        end

                    end
                end


                if size(X,2) ~= size(X_temp,2) && size(X,2) ~= 0
                    disp("Error: X_temp does not match the X length")
                    errorfile_list = [errorfile_list; string(active_file)];
                    continue
                end

                X = [X; X_temp]; %add data to X
                objectID = [objectID; cellobjectID]; %add objectID data
                if contains(type, "Live")
                    T_labels = [T_labels; T_labels_temp];
                end
                

                %Determine which cell line the data is for based on the filename
                for c = 1:length(celllines)
                    if contains(active_file, celllines(c))
                        cellline_name = celllines(c);
                        
                    end
                end


                %Add label to X_labels
                X_labels_temp = string(zeros(file_length, 1));
                X_labels_temp(1:file_length, 1) = cellline_name;
                X_labels = [X_labels; X_labels_temp]; %#ok<*AGROW>
                cell_list = [cell_list; append(cellline_name, ' ', string(cellnum_str))];
                cellX_labels = [cellX_labels; append(X_labels_temp, ' ', string(cellnum_str))];
            end

            %Remove all objects with a negative volume; this removes erroneous results
            volume_idx = contains(param_labels, 'Volume');
            X_temp = X;
            for i = 1:length(X)
                if (X(i, volume_idx) < 0)
                    X_temp(i,:) = [];
                    X_labels(i) = [];
                    objectID(i) = [];
                    if contains(type, "Live")
                        T_labels(i) = [];
                    end
                end
            end
            
            %TP_peaks = [findpeaks(T_labels); T_labels(end)];
            %TPcelldata = [modifiedfiles num2cell(TP_peaks)];

            %TP assessment
                if contains(type, "Live") && isequal(tp, []) && pool == 0
                    %remove TP with 3 or less objects
                    d = [true, diff(T_labels).' ~= 0, true];  % TRUE if values change
                    n = diff(find(d));               % Number of repetitions
                    consec = repelem(n, n).';
                    
                    X_temp(consec(:) <= 3,:) = [];
                    X_labels(consec(:) <= 3) = [];
                    cellX_labels(consec(:) <= 3) = [];
                    objectID(consec(:) <= 3) = [];
                    T_labels(consec(:) <= 3) = [];
                elseif contains(type, "Live") && ~isequal(tp, [])
                    currentTP = ismember(T_labels,tp);

                    X_temp = X_temp(currentTP,:);
                    X_labels = X_labels(currentTP,:);
                    cellX_labels = cellX_labels(currentTP,:);
                    objectID = objectID(currentTP,:);
                    T_labels = T_labels(currentTP,:);
                end


            X = X_temp;
            
    end

    function [X_new, mmdist_data] = parameter_calc(X, T_labels, objectID, cell_list, cellX_labels)
        


        %~~Non-DPG Secondary Parameters~~
        progressbar([], [], [], 0, 0)
       
        area = X(:,contains(param_labels, 'Area'));
        volume = X(:,contains(param_labels, 'Volume'));
        bbaa_x = X(:,contains(param_labels, "BB AA X"));
        bbaa_z = X(:,contains(param_labels, "BB AA Z"));
        bboo_x = X(:,contains(param_labels, 'BB OO X'));
        bboo_z = X(:,contains(param_labels, 'BB OO Z'));
        pos_x = X(:,contains(param_labels, 'Position X'));
        pos_y = X(:,contains(param_labels, 'Position Y'));
        pos_z = X(:,contains(param_labels, 'Position Z'));

        ci = (area.^3) ./ ((16* (pi^2) ).* (volume.^2));
        mbi_aa = bbaa_x ./ bbaa_z;
        mbi_oo = bboo_x ./ bboo_z;
        [polarity,~]=cart2pol(pos_x,pos_y,pos_z);

        %add data for CI, MBI, and Polarity to data array
        X_new = [X ci mbi_aa mbi_oo polarity];
        
        
        %~~DPG Calculation~~
        progressbar([], [], [], .1, 0)
        posx_idx = find(contains(param_labels, 'Position X'));
        posy_idx = find(contains(param_labels, 'Position Y'));
        posz_idx = find(contains(param_labels, 'Position Z'));
        
        cellnum = length(cell_list);
        
        %Collect DPG Data
        for i = 1:cellnum
            progressbar([], [], [], [], (i-1)/cellnum)
            cellrange = matches(cellX_labels, cell_list(i));
            cell_idx = find(cellrange == 1);
            current_mmdist_data = zeros(length(nonzeros(cellrange))); %allocated an empty array
            for x = 1:length(nonzeros(cellrange)) %for every object in the cell
                for y = 1:length(nonzeros(cellrange)) %for every object in the cell (comparison)
                    if x == y %if comparing the same object, set the distance to 0 and move on
                        current_mmdist_data(x,y) = 0;
                        continue;
                    end

                    obj1_idx = cell_idx(x);
                    obj2_idx = cell_idx(y);

                    %array of the objects' positions [X, Y, Z]
                    obj1_pos = X(obj1_idx, [posx_idx, posy_idx, posz_idx]);
                    obj2_pos = X(obj2_idx, [posx_idx, posy_idx, posz_idx]);

                    %calculate the distance between these objects
                    mm_dist = sqrt((obj1_pos(1)-obj2_pos(1))^2 ...
                                 + (obj1_pos(2)-obj2_pos(2))^2 ...
                                 + (obj1_pos(3)-obj2_pos(3))^2);

                    %put this data in the array
                    current_mmdist_data(x,y) = mm_dist;
                end
            end

            %the current_mmdist_data at this point in the code contains an array
            %where each row and column represent mitochondrial objects in an individual cell. For
            %example, current_mmdist_data(i,j) = distance between object i and
            %object j. This data is then stored in the cell array.
            mmdist_data{i} = current_mmdist_data;
        end
        
        %Calculate DPG Parameters
        progressbar([], [], [], .7, 0)
        
        
        min_mmdist = [];
        max_mmdist = [];
        mean_mmdist = [];
        median_mmdist = [];
        std_mmdist = [];
        sum_mmdist = [];
        skewness_mmdist = [];
        kurtosis_mmdist = [];

        
        
        error1_tp = [];
        error2_tp = [];

        for i = 1:length(mmdist_data)  %for every cell's DPG array
            current_mmdist_data = cell2mat(mmdist_data(i)); %the current Mito Mito Distance array
            progressbar([], [], [], [], (i-1)/length(mmdist_data))

            cellrange = matches(cellX_labels, cell_list(i));
            
            
            if contains(type, "Live")
                current_T_labels = T_labels(cellrange);
            end
            
            for j = 1:length(current_mmdist_data)  %for every object in that array
                if contains(type, "Live") && pool == 0
                    T_range = current_T_labels == current_T_labels(j);
                    obj_mmdist = nonzeros(current_mmdist_data(j, T_range)); %removes the zero representing the same object
                else
                    obj_mmdist = nonzeros(current_mmdist_data(j, :));
                end

                %Debugging
                %{
                if contains(type, "Live") && isempty(obj_mmdist)
                    error1_tp = [error1_tp; current_T_labels(j)];
                end
                if contains(type, "Live") && isempty(min(obj_mmdist))
                    error2_tp = [error2_tp; {current_T_labels}];
                end
                %}
                
                min_mmdist = [min_mmdist; min(obj_mmdist)]; %minimum value of the Mito-Mito Distance distribution for that object
                max_mmdist = [max_mmdist; max(obj_mmdist)]; %maximum value of the Mito-Mito Distance distribution for that object
                mean_mmdist = [mean_mmdist; mean(obj_mmdist)]; %mean value of the Mito-Mito Distance distribution for that object
                median_mmdist = [median_mmdist; median(obj_mmdist)]; %median Mito-Mito Distance value
                std_mmdist = [std_mmdist; std(obj_mmdist)]; %the standard deviation of the Mito-Mito Distance distribution for that object
                sum_mmdist = [sum_mmdist; sum(obj_mmdist)]; %the sum of the Mito-Mito Distance distribution for that object
                skewness_mmdist = [skewness_mmdist; skewness(obj_mmdist)]; %the skewness of the Mito-Mito Distance distribution for that object; this value represents how "assymmetric" the data is 
                kurtosis_mmdist = [kurtosis_mmdist; kurtosis(obj_mmdist)]; %the kurtosis of the Mito-Mito Distance distribution for that object; this value represents the "tailedness" of the data compared to a normal curve
            end
        end

        %Put these new parameters in the dataset

        X_new = [X_new min_mmdist max_mmdist mean_mmdist median_mmdist std_mmdist ...
            sum_mmdist skewness_mmdist kurtosis_mmdist sum_mmdist./volume ...
            sum_mmdist./pos_z sum_mmdist.*volume sum_mmdist.*pos_z];

       %add the respective parameter labels
       param_labels = [param_labels 'Min Dist' 'Max Dist' 'Mean Dist' ...
            'Median Dist' 'Std Dist' 'Sum Dist' 'Skewness Dist' ...
            'Kurtosis Dist' 'Sum/Vol Dist' 'Sum/Pos Z Dist' ...
            'Sum*Vol Dist' 'Sum*Pos Z Dist'];
    end
end
