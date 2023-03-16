function IMARISDataImport_06252021_CellNucEdit(celllines_color, celllines, maindir, root)
   comp = ["Area", "BoundingBoxAA", 'BoundingBoxOO',...
      'Ellipticity (oblate)', 'Ellipticity (prolate)', 'Ellipsoid Axis A',...
      'Ellipsoid Axis B', 'Ellipsoid Axis C', 'Ellipsoid Axis Length A',...
      'Ellipsoid Axis Length B', 'Ellipsoid Axis Length C','Number of Triangles',...
      'Number of Voxels', 'Sphericity', 'Volume' ]; 
    param_labels = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X',...
      'BB OO Y', 'BB OO Z', 'Oblate','Prolate',...
      'Ellipsoid A X', 'Ellipsoid A Y', 'Ellipsoid A Z', 'Ellipsoid B X', ...
      'Ellipsoid B Y', 'Ellipsoid B Z', 'Ellipsoid C X', 'Ellipsoid C Y',...
      'Ellipsoid C Z', 'Ellipsoid Length A', 'Ellipsoid Length B', 'Ellipsoid Length C',...
      'Triangles', 'Voxels', 'Sphericity', 'Volume', 'CI', 'BI AA', 'BI OO']; %Note: this variable gets added to and reordered %Note: this variable gets added to and reordered
    warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
    
    progressbar([], [], 0, 0, 0) 
    
    %Implement a dialog box for this part later on
    import_dir_cell = [maindir 'IMARIS Data\Cell'];
    import_dir_nuc = [maindir 'IMARIS Data\Nuc'];
    save_dir = [maindir 'MATLAB Data'];

    save_filename = [root '_ImportedIMARISData.mat'];

    %~~PART 1: PRIMARY PARAMETER IMPORTATION~~
    [X_cell, X_labels, objectID] = parameter_import(import_dir_cell);
    [X_nuc, ~, ~] = parameter_import(import_dir_nuc);
    progressbar([], [], .4, 0, 0)
    

    %~~PART 2: SECONDARY PARAMETER CALCULATION~~
    [X_cell] = parameter_calc(X_cell, objectID);
    [X_nuc] = parameter_calc(X_nuc, objectID);
    progressbar([], [], .8, 0, 0)
    
    %~~PART 3: REORDER PARAMETERS ALPHABETICALLY~~\
    [param_labels, sort_idx] = sort(param_labels);
    X_cell = X_cell(:,sort_idx);
    X_nuc = X_nuc(:,sort_idx);
    progressbar([], [], .85, 0, 0)

    param_labels = [strcat('Cell ', param_labels), strcat('Nuc ', param_labels)];
    X = [X_cell, X_nuc];
    
    %~~PART 4: MAT FILE EXPORTATION
    cd(save_dir)
    save(save_filename)
    cd ../

    %~~FUNCTION DEFINITIONS~~
    function [X, X_labels, objectID] = parameter_import(location)
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
            lengths = [];
            
            for i = 1:length(files) %for every excel file
                active_file = files(i); %current Excel filepath
                full_sheets = string(sheetnames(ds1, i)); %The list of sheet names for the file
                sheets_index = find(contains(full_sheets, comp)); %limit the importation to only the relevant sheets
                lengths = [lengths length(active_file)];
                
                X_temp = [];
                progressbar([], [], [], (i-1)/length(files), 0)
                
                for k = 1:length(sheets_index) %for every relevant sheet in the excel file
                    var = sheets_index(k); %current sheet index
                    active_sheet = full_sheets(var); %current sheet name

                    %Update waitbar
                    progressbar([], [], [], [], (k-1)/length(sheets_index)) 

                    %~~SPECIAL CASES~~
                    %Bounding Box: 3 Parameters
                    if contains(active_sheet, "BoundingBox") || contains(active_sheet, "Ellipsoid Axis A") || ...
                            contains(active_sheet, "Ellipsoid Axis B") || contains(active_sheet, "Ellipsoid Axis C")
                        imported_table = readtable(string(active_file), 'Range', 'A:C', 'Sheet', active_sheet, 'VariableNamingRule', 'modify');
                        temp = table2array(imported_table);
                        X_temp = [X_temp temp];

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

        ci = (area.^3) ./ ((16* (pi^2) ).* (volume.^2));
        mbi_aa = bbaa_x ./ bbaa_z;
        mbi_oo = bboo_x ./ bboo_z;

        %add data for CI, MBI, and Polarity to data array
        X_new = [X ci mbi_aa mbi_oo];

end
end