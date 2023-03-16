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

%{
%Fixed3D
%2D 4CL Mito
celllines = ["AU565", "MCF10A", "MDA231", "T47D"];
%3D 4CL Mito
celllines = ["AU5653DM", "MCF10A3DM", "MDA2313DM", "T47D3DM"];
%2D+3D 4CL Mito
celllines = ["AU565", "MCF10A", "MDA231", "T47D", "AU5653DM", "MCF10A3DM", "MDA2313DM", "T47D3DM"];
%2D+3D AU565 Mito
celllines = ["AU565", "AU5653DM"];
%2D+3D MCF10A Mito
celllines = ["MCF10A", "MCF10A3DM"];
%2D+3D MDA231 Mito
celllines = ["MDA231", "MDA2313DM"];
%2D+3D T47D Mito
celllines = ["T47D", "T47D3DM"];

%Live2D Datasets
%5CL
celllines = ["MCFWT", "MDAKO", "MDAWT", "T47DKO", "T47DWT"];
%EEC
%Mito
%EECMito Inter
%}

%}
progressbar(1,1,1,1,1)

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
function CompleteRFScript(celllines_color, celllines, dir, root, script_dir, specialcase, progress)
    import = 1; rf = 1; export = 1;
    if strcmp(specialcase, 'noimport')
        import = 0;
    elseif strcmp(specialcase, 'exportonly')
        import = 0; rf = 0;
    elseif strcmp(specialcase, 'importonly')
        rf = 0; export = 0;
    elseif strcmp(specialcase, 'alltp')
        import = 2;
    end

    progressbar('MainScript', root, 'Importing', '', '')
    progressbar(progress, 0)
    if (import == 1)
        IMARISDataImport_12222022(celllines_color, celllines, dir, root); cd(script_dir); 
    elseif (import == 2)
        
    end

    progressbar('MainScript', root, 'Classification', '', '')
    progressbar(progress, .33)
    if (rf == 1)
        RandomForest_12222022(celllines_color, celllines, dir, root); cd(script_dir);
    end

    progressbar('MainScript', root, 'Exporting', '', '')
    progressbar(progress, .67)
    if (export == 1)
        MATLABDataExport_12222022(dir, root); cd(script_dir);
    end
    
end
