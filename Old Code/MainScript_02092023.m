clear
clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

script_dir = cd;
celllines_color = ''; 
progressbar('MainScript', '', '', '', '')

%dialog box code running
%[celllines, dir, root] = DatasetDirSelection(script_dir);
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.15)

%coded predefined code running
%Fixed2D Datasets:
%{
celllines = ["MCF10A", "MDA231", "MDA436", "MDA468", "AU565", "T47D"];

dir = [script_dir '\Datasets\Fixed2D 6CL\Mito\']; root = '2D6CL-Mito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, '', 0.01)

dir = [script_dir '\Datasets\Fixed2D 6CL\EEC\']; root = '2D6CL-EEC';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.18)

dir = [script_dir '\Datasets\Fixed2D 6CL\ERC\']; root = '2D6CL-ERC';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.36)

dir = [script_dir '\Datasets\Fixed2D 6CL\EECERCInt\']; root = '2D6CL-EECERCInt';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.54)

dir = [script_dir '\Datasets\Fixed2D 6CL\EECMitoInt\']; root = '2D6CL-EECMitoInt';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.72)

dir = [script_dir '\Datasets\Fixed2D 6CL\ERCMitoInt\']; root = '2D6CL-ERCMitoInt';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.90)
%}

%Live2D Datasets - All TP
%5CL
celllines = ["MCF10AWT", "MDAKO", "MDAWT", "T47DKO", "T47DWT"];

%dir = [script_dir '\Datasets\Live2D 5CL\Mito 5CL ko+wt\']; root = 'Live2D5CL-Mito';
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'alltp', 0.01)

%dir = [script_dir '\Datasets\Live2D 5CL\ERC 5CL ko+wt\']; root = 'Live2D5CL-ERC';
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'alltp', 0.18)
dir = [script_dir '\TEST\']; root = 'TEST'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ['Live-nonpool-exportonly'], 0.36, [])

%}

progressbar(1)

function [celllines, dir, root] = DatasetDirSelection(script_dir)
        %Select Celllines
        celllinelist = {"~ Fixed 2D ~", "   MCF10A", "   MDA231", "   MDA436", "   MDA468", "   AU565", "   T47D",...
            "~ Fixed 3D ~", "   MCF10A3DM", "   MDA2313DM", "   AU5653DM", "   T47D3DM", ...
            "~ Live 2D ~", "   MCFWT", "   MDAKO", "   MDAWT", "   T47DKO", "   T47DWT"};
        [indx,tf] = listdlg('ListString',celllinelist);

        %adjust selection to usable array (remove spaces and selected headers
        selec = strrep(cellstr(celllinelist(indx)), " ", "");
        headers = strcmp(selec, "~ Fixed 2D ~") | strcmp(selec, "~ Fixed 3D ~") | strcmp(selec, "~ Live 2D ~");
        selec(headers) = [];
        

        %Select and Make Directories
        input = inputdlg({'IMARIS Excel Directory','Export Directory','Root'},...
              'Dataset Selection', [1 50; 1 50; 1 20]); 
        datadir = input{1};
        expdir = input{2};
        root = input{3};
        
        mkdir(strcat(expdir, '\IMARIS Data'))
        mkdir(strcat(expdir, '\MATLAB Data'))
        mkdir(strcat(expdir, '\Figures'))
        
        cd(datadir)
        for i = 1: length(selec)
            [status, message] = copyfile(strcat(selec(i),'*'), strcat(expdir, '\IMARIS Data'));
            if status == 1
                message
            end
        end
        cd(script_dir)
        
        
        celllines = selec;
        dir = strcat(expdir, '\');



end
function CompleteRFScript(celllines_color, celllines, dir, root, script_dir, specialcase, progress, tp, type)
    import = 1; rf = 1; export = 1; pool = 0;
    if contains(specialcase, 'noimport')
        import = 0;
    elseif contains(specialcase, 'exportonly')
        import = 0; rf = 0;
    elseif contains(specialcase, 'importonly')
        rf = 0; export = 0;
    end

    if contains(specialcase, 'Live')
        type = 'Live';
        if contains(specialcase, 'pool')
            pool = 1;
        end
        if contains(specialcase, 'nonpool')
            pool = 0;
        end
    elseif contains(specialcase, 'Track')
        type = 'Track';
    else
        type = 'Fixed';
    end

    progressbar('MainScript', root, 'Importing', '', '')
    progressbar(progress, 0)
    if (import == 1)
        IMARISDataImport_02092023(celllines_color, celllines, dir, root, type, tp, pool); cd(script_dir); 
    end

    progressbar('MainScript', root, 'Classification', '', '')
    progressbar(progress, .33)
    if (rf == 1)
        RandomForest_12222022(celllines_color, celllines, dir, root); cd(script_dir);
    end

    progressbar('MainScript', root, 'Exporting', '', '')
    progressbar(progress, .67)
    if (export == 1)
        MATLABDataExport_02092023(dir, root, type); cd(script_dir);
    end
    
end
