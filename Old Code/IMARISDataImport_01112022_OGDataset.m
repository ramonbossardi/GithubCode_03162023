function IMARISDataImport_01112022_OGDataset(celllines_color, celllines, maindir, root)
    comp = ["Area", "BoundingBoxAA", 'BoundingBoxOO', 'Distance from Origin Ref',...
      'Ellipticity (oblate)', 'Ellipticity (prolate)', 'Number of Triangles', 'Number of Voxels', ...
      'Position Reference Frame' 'Sphericity', 'Volume' ]; 
    param_labels = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X',...
      'BB OO Y', 'BB OO Z', 'Dist Origin', 'Oblate','Prolate',...
      'Triangles', 'Voxels', 'Position X', 'Position Y', 'Position Z',...
      'Sphericity', 'Volume', 'CI', 'BI AA', 'BI OO', 'Polarity']; %Note: this variable gets added to and reordered
    warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
    
    progressbar([], [], 0, 0, 0) 
    
    %Implement a dialog box for this part later on
    import_dir = [maindir 'IMARIS Data'];
    save_dir = [maindir 'MATLAB Data'];

    save_filename = [root '_ImportedIMARISData.mat'];

    %~~PART 1: PRIMARY PARAMETER IMPORTATION~~
    [X, X_labels, objectID, cell_list] = parameter_import(import_dir);
    progressbar([], [], .4, 0, 0)
    

    %~~PART 2: SECONDARY PARAMETER CALCULATION~~
    [X] = parameter_calc(X, objectID);
    progressbar([], [], .8, 0, 0)
    
    %~~PART 3: REORDER PARAMETERS ALPHABETICALLY~~\
    [param_labels, sort_idx] = sort(param_labels);
    X = X(:,sort_idx);
    progressbar([], [], .85, 0, 0)

    %~~PART 4: MAT FILE EXPORTATION
    cd(save_dir)
    save(save_filename)
    cd ../

    %~~FUNCTION DEFINITIONS~~
    function [X, X_labels, objectID, cell_list] = parameter_import(location)
            %Loading Bar
            progressbar([], [], [], 0, 0) 
            dir(location)

            %ds0 = spreadsheetDatastore(location, 'Range', 'B5:B6', 'Sheets', {'Overall'});
            %num_objects = sum(table2array((readall(ds0))));
            ds1 = spreadsheetDatastore(location);
            files = ds1.Files;

            %data array allocation
            X = [];
            X_labels = [];
            objectID = [];
            cell_list = [];
            
            for i = 1:length(files) %for every excel file
                active_file = files(i); %current Excel filepath
                full_sheets = string(sheetnames(ds1, i)); %The list of sheet names for the file
                sheets_index = find(contains(full_sheets, comp)); %limit the importation to only the relevant sheets

                X_temp = [];
                progressbar([], [], [], (i-1)/length(files), 0)
                dapi_import = 0;
                
                for k = 1:length(sheets_index) %for every relevant sheet in the excel file
                    var = sheets_index(k); %current sheet index
                    active_sheet = full_sheets(var); %current sheet name

                    %Update waitbar
                    progressbar([], [], [], [], (k-1)/length(sheets_index)) 

                    %~~SPECIAL CASES~~

                    %Bounding Box: 3 Parameters
                    if contains(active_sheet, "BoundingBox")
                        imported_table = readtable(string(active_file), 'Range', 'A:C', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                        temp = table2array(imported_table);
                        X_temp = [X_temp temp];

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
                        cell_list = unique([cell_list string(cellnum_str)]);
                      
                        
                        cellnum_index = contains(cellnum_data, string(cellnum)); %select only data indices with matching cell number
                        if sum(cellnum_index) == 0
                            error = strcat('Cell Reference Undetected. Automatically importing all reference data: ', cellnum_filename)
                            cellnum_index(:) = 1;
                        end
                        
                        if contains(active_sheet, 'Distance') %Distance from Origin
                            %import 1 column for Distance data
                            imported_table = readtable(string(active_file), 'Range', 'A:A', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = table2array(imported_table);
                            
                            X_temp = [X_temp temp(cellnum_index)];
                        else  %Position
                            %import 3 columns for Position data
                            imported_table = readtable(string(active_file), 'Range', 'A:C', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = table2array(imported_table);
                            
                            X_temp = [X_temp temp(cellnum_index,:)];
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
                        surfdist_string1 = strcat("cell", string(cellnum), " DAPI");
                        surfdist_string2 = strcat("dapi cell", string(cellnum));
                        surfdist_string3 = strcat("DAPI ", string(cellnum));

                        %Import appropiate data
                        if (contains(surfdist_IDdata(end), surfdist_string1,'IgnoreCase',true) || ...
                                contains(surfdist_IDdata(end), surfdist_string2,'IgnoreCase',true) || ...
                                contains(surfdist_IDdata(end), surfdist_string3,'IgnoreCase',true)) && (dapi_import == 0)
                            %import 1 column for Distance to Surface
                            imported_table = readtable(string(active_file), 'Range', 'A:A', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                            temp = table2array(imported_table);
                            X_temp = [X_temp temp];
                            dapi_import = 1;
                        end

                    %~~DEFAULT IMPORTATION~~
                    else
                        %import 1 column for every other primary component
                        imported_table = readtable(string(active_file), 'Range', 'A:A', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                        temp = table2array(imported_table);
                        X_temp = [X_temp temp];
                        
                        file_length = length(temp); %record number of objects for reference
                        cellobjectID = (0:(file_length-1)).'; %Stores cellobjectID
                    end
                end

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
            end

            %Remove all objects with a negative volume; this removes erroneous results
            volume_idx = contains(param_labels, 'Volume');
            X_temp = X;
            for i = 1:length(X)
                if (X(i, volume_idx) < 0)
                X_temp(i,:) = [];
                X_labels(i) = [];
                objectID(i) = [];
                end
            end
            X = X_temp;
    end

    function [X_new] = parameter_calc(X, objectID)
        
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
         
    end
end
