function IMARISDataImport_06202021_LiveTime5Edit(celllines_color, celllines, maindir, root)
    comp = ["Area", "BoundingBoxAA", 'BoundingBoxOO', 'Distance from Origin Ref',...
      'Ellipticity (oblate)', 'Ellipticity (prolate)', 'Number of Triangles', 'Number of Voxels', ...
      'Position Reference Frame', 'Shortest Distance to Surfac', 'Sphericity', 'Volume' ]; 
    param_labels = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X',...
      'BB OO Y', 'BB OO Z', 'Dist Origin', 'Oblate','Prolate',...
      'Triangles', 'Voxels', 'Position X', 'Position Y', 'Position Z', 'Dist Surface',...
      'Sphericity', 'Volume', 'CI', 'BI AA', 'BI OO', 'Polarity']; %Note: this variable gets added to and reordered
    bar = waitbar(0, 'Importing Dataset');

    %Implement a dialog box for this part later on
    import_dir = [maindir 'IMARIS Data'];
    save_dir = [maindir 'MATLAB Data'];

    save_filename = [root '_ImportedIMARISData.mat'];

    %~~PART 1: PRIMARY PARAMETER IMPORTATION~~
    [X, X_labels, objectID] = parameter_import(import_dir);
    close(bar)

    %~~PART 2: SECONDARY PARAMETER CALCULATION~~
    bar = waitbar(.60,  'Calculating Secondary Parameters');
    [X, dpg_data] = parameter_calc(X, objectID);
    close(bar)

    %~~PART 3: REORDER PARAMETERS ALPHABETICALLY~~\
    bar = waitbar(.85,  'Reordered Parameters');
    [param_labels, sort_idx] = sort(param_labels);
    X = X(:,sort_idx);

    %~~PART 4: MAT FILE EXPORTATION
    waitbar(.90, bar, 'Saving Data');
    close(bar)

    cd(save_dir)
    save(save_filename)
    cd ../

    %added a special sound effect that plays when the code is done
    bar = waitbar(1, 'Data Successfully Imported!');
    close(bar)

    %~~FUNCTION DEFINITIONS~~
    function [X, X_labels, objectID] = parameter_import(location)

            %Loading Bar
            import_bar = waitbar(0, 'Please wait...');
            progress = 0;

            dir(location)
            
            %LIVE EDIT: DETERMINE RANGE TO IMPORT
            
            
            
            ds1 = spreadsheetDatastore(location);
            files = ds1.Files;

            %data array allocation
            X = [];
            X_labels = [];
            objectID = [];

            for i = 1:length(files) %for every excel file
                active_file = files(i); %current Excel filepath
                full_sheets = string(sheetnames(ds1, i)); %The list of sheet names for the file
                sheets_index = find(contains(full_sheets, comp)); %limit the importation to only the relevant sheets

                X_temp = [];

                for k = 1:length(sheets_index) %for every relevant sheet in the excel file
                    var = sheets_index(k); %current sheet index
                    active_sheet = full_sheets(var); %current sheet name
                    
                    
                    
                    
                    %Update waitbar
                    waitbar(progress, import_bar, strcat({'Importing data: File '}, string(i),...
                        {' of '}, string(length(files)), {', Sheet '}, string(k), {' of '}, ...
                        string(length(sheets_index))));
                    progress = progress + 1/(length(sheets_index)*length(files));

                    %~~SPECIAL CASES~~

                    %Bounding Box: 3 Parameters
                    if contains(active_sheet, "BoundingBox")
                        ds = spreadsheetDatastore(location, 'NumHeaderLines', 1); %import 3 columns for BoundingBox data
                        ds.Files = active_file;
                        ds.Sheets = var;
                        ds.Range = sprintf(range_txt, 'A', 'C');

                        %Add to the data array for the current file
                        temp = table2array(readall(ds)); X_temp = [X_temp temp];

                    %Distance from Origin + Position: Reference Different Cell Nucleui.
                    %only import data that references the correct cell number
                    elseif contains(active_sheet, 'Distance from Origin') || contains(active_sheet, 'Position')

                        %Adjust reference indicator column location
                        if contains(active_sheet, 'Distance from Origin') %Distance from Origin
                            ds = spreadsheetDatastore(location, 'NumHeaderLines', 1);
                            ds.Files = active_file;
                            ds.Sheets = var;
                            ds.Range = sprintf(range_txt, 'E', 'E');
                        else  %Position
                            ds = spreadsheetDatastore(location, 'NumHeaderLines', 1);
                            ds.Files = active_file;
                            ds.Sheets = var;
                            ds.Range = sprintf(range_txt, 'G', 'G');
                        end

                        cellnum_data = table2array(readall(ds)); %contains the reference numbers the data

                        %IF SOMETHING IS WRONG WITH ALL REFERENCE PARAMETERS,
                        %CHECK HERE IF THE FILE NAME CHANGED

                        %This code assumes the file name is "(cellline) cell#  ........."

                        match = wildcardPattern + "\";
                        cellnum_filename = erase(active_file, match);
                        cellnum_str = regexp(cellnum_filename, 'cell\d*', 'match');
                        cellnum = sscanf(string(cellnum_str), 'cell%f');

                        cellnum_index = contains(cellnum_data, string(cellnum)); %select only data indices with matching cell number

                        if contains(active_sheet, 'Distance') %Distance from Origin
                            %import 1 column for Distance data
                            ds = spreadsheetDatastore(location, 'NumHeaderLines', 1);
                            ds.Files = active_file;
                            ds.Sheets = var;
                            ds.Range = sprintf(range_txt, 'A', 'A');

                            %add to data array for that file
                            temp = table2array(readall(ds)); X_temp = [X_temp temp(cellnum_index)];
                        else  %Position
                            %import 3 columns for Position data
                            ds = spreadsheetDatastore(location, 'NumHeaderLines', 1);
                            ds.Files = active_file;
                            ds.Sheets = var;
                            ds.Range = sprintf(range_txt, 'A', 'C');

                            %add to data array for that file
                            temp = table2array(readall(ds)); X_temp = [X_temp temp(cellnum_index,:)];
                        end

                    %Distance to Nucleus Surface: Limit to Sheet with Appropiate Cell DAPI Data.
                    elseif contains(active_sheet, 'Shortest Distance') 

                        %Import the column indicating the data type
                        ds = spreadsheetDatastore(location, 'NumHeaderLines', 1);
                        ds.Files = active_file;
                        ds.Sheets = var;
                        ds.Range = sprintf(range_txt, 'D', 'D');
                        
                        surfdist_IDdata = table2array(readall(ds));

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
                        if contains(surfdist_IDdata(end), surfdist_string1,'IgnoreCase',true) || ...
                                contains(surfdist_IDdata(end), surfdist_string2,'IgnoreCase',true) || ...
                                contains(surfdist_IDdata(end), surfdist_string3,'IgnoreCase',true)

                            %import 1 column for Distance to Surface
                            ds = spreadsheetDatastore(location, 'NumHeaderLines', 1);
                            ds.Files = active_file;
                            ds.Sheets = var;
                            ds.Range = sprintf(range_txt, 'A', 'A');

                            %add to data array for that file
                            temp = table2array(readall(ds)); X_temp = [X_temp temp];
                        end

                    %~~DEFAULT IMPORTATION~~
                    else
                        %import 1 column for every other primary component
                        ds = spreadsheetDatastore(location, 'NumHeaderLines', 1);
                        ds.Files = active_file;
                        ds.Sheets = var;
                        ds.Range = sprintf(range_txt, 'A', 'A');

                        %add to data array for that file
                        temp = table2array(readall(ds)); X_temp = [X_temp temp];

                        file_length = length(temp); %record number of objects for reference
                        cellobjectID = (0:(file_length-1)).'; %Stores cellobjectID
                    end
                end
                
                i = i
                
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

            waitbar(1, import_bar, 'Finishing');
            close(import_bar);
    end
    function [X_new, mmdist_data] = parameter_calc(X, objectID)
        
        %~~Non-DPG Secondary Parameters~~
        calc_bar = waitbar(0, 'Calculating Non-DPG Secondary Parameters');
        
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
        waitbar(.2, calc_bar, 'Calculating DPG Distributions: Loading...');
        posx_idx = find(contains(param_labels, 'Position X'));
        posy_idx = find(contains(param_labels, 'Position Y'));
        posz_idx = find(contains(param_labels, 'Position Z'));
        
        cellnum = sum(objectID(:) == 0);
        mmdist_data = cell(cellnum,1);
        start_index = find(objectID(:) == 0);
        
        progress = 0;
        %Collect DPG Data
        for i = 1:cellnum
            cellstart = start_index(i);
            %The ending index is either the index before the start of the next cell
            %or the last index in the special case of the last cell.
            if i == cellnum
                %last cell
                cellend = length(objectID);
            else
                cellend = start_index(i+1) - 1;
            end
            cellrange = cellstart:cellend;

            current_mmdist_data = zeros(length(cellrange)); %allocated an empty array

            
            for x = 1:length(cellrange) %for every object in the cell
                waitbar(.2 + progress, calc_bar, strcat({'Calculating DPG Distributions: Cell '}, string(i),...
                    {' of '}, string(cellnum), {', Object '}, string(x), {' of '}, ...
                    string(length(cellrange))));
                progress = progress + .6/cellnum/length(cellrange);
                
                for y = 1:length(cellrange) %for every object in the cell (comparison)

                    
                    if x == y %if comparing the same object, set the distance to 0 and move on
                        current_mmdist_data(x,y) = 0;
                        continue;
                    end

                    obj1_idx = cellrange(x);
                    obj2_idx = cellrange(y);

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
        waitbar(.8, calc_bar, 'Calculating DPG Secondary Parameters: Loading...');
        progress = 0;
        
        min_mmdist = [];
        max_mmdist = [];
        mean_mmdist = [];
        median_mmdist = [];
        std_mmdist = [];
        sum_mmdist = [];
        skewness_mmdist = [];
        kurtosis_mmdist = [];
        for i = 1:length(mmdist_data)  %for every cell's Mito Mito Distance array
            current_mmdist_data = cell2mat(mmdist_data(i)); %the current Mito Mito Distance array
            
            for j = 1:length(current_mmdist_data)  %for every object in that array
                waitbar(.8 + progress, calc_bar, strcat({'Calculating DPG Secondary Parameters: Cell '}, string(i),...
                    {' of '}, string(length(mmdist_data)), {', Object '}, string(j), {' of '}, ...
                    string(length(current_mmdist_data))));
                progress = progress + .2/length(mmdist_data)/length(current_mmdist_data);
                
                obj_mmdist = nonzeros(current_mmdist_data(j,:)); %removes the zero representing the same object

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
        
        waitbar(1, calc_bar, 'Calculations Complete');
        close(calc_bar)
    end

end
