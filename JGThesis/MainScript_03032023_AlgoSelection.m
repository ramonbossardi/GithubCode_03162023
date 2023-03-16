clear
clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

script_dir = cd;
celllines_color = ''; 
progressbar('MainScript', '', '', '', '')

%UI Runs
%dialog box code running
%[celllines, dir, root, mode] = DatasetDirSelection(script_dir);
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, mode, 0.15, [])

%PreDefined Runs
%2D 6CL
celllines = ["MCF10A", "MDA231", "T47D"];
%dir = [script_dir '\Datasets\Fixed2D 6CL\EEC\']; root = 'EEA1'; 
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.01, [])
%dir = [script_dir '\Datasets\Fixed2D 6CL\EECERCInt\']; root = 'SCA-TfEEA1'; 
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.05, [])
%dir = [script_dir '\Datasets\Fixed2D 6CL\EECMitoInt\']; root = 'SCA-Tom20EEA1'; 
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.1, [])
%dir = [script_dir '\Datasets\Fixed2D 6CL\ERC\']; root = 'Tf'; 
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.15, [])
%dir = [script_dir '\Datasets\Fixed2D 6CL\ERCMitoInt\']; root = 'SCA-TfTom20'; 
% CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.2, [])
dir = [script_dir '\Datasets\Fixed2D 6CL\Mito\']; root = 'Tom20'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed-noimport', 0.25, [])

%Live2D 5CL
celllines = ["MCF10AWT", "MDAKO", "MDAWT", "T47DKO", "T47DWT"];
%dir = [script_dir '\Datasets\Live2D 5CL\ERC 5CL ko+wt\']; root = 'EEC-NonPool'; 
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Live-nonpool', 0.30, [])
%dir = [script_dir '\Datasets\Live2D 5CL\ERC 5CL ko+wt\']; root = 'EEC-Pool'; 
%CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Live-pool', 0.35, [])
dir = [script_dir '\Datasets\Live2D 5CL\ERCMitoInt 5CL ko+wt\']; root = 'SCA-NonPool'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Live-nonpool', 0.40, [])
dir = [script_dir '\Datasets\Live2D 5CL\ERCMitoInt 5CL ko+wt\']; root = 'SCA-Pool'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Live-pool', 0.45, [])
dir = [script_dir '\Datasets\Live2D 5CL\Mito 5CL ko+wt\']; root = 'Mito-NonPool'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Live-nonpool', 0.50, [])
dir = [script_dir '\Datasets\Live2D 5CL\Mito 5CL ko+wt\']; root = 'Mito-Pool'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Live-pool', 0.55, [])

%Fixed Rab4A
celllines = ["KD1", "KD4", "NTC"];
dir = [script_dir '\Datasets\Rab4A excel\CD63 Rab4A\']; root = 'CD63'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.60, [])
dir = [script_dir '\Datasets\Rab4A excel\EEA1 Rab4A\']; root = 'EEA1'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.65, [])
dir = [script_dir '\Datasets\Rab4A excel\Tom20 CD63 Rab4A\']; root = 'Mito-CD63'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.70, [])
dir = [script_dir '\Datasets\Rab4A excel\Tom20 EEA1 Rab4A\']; root = 'Mito-EEA1'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.75, [])
dir = [script_dir '\Datasets\Rab4A excel\SCA CD63-Mito Rab4A\']; root = 'SCA-CD63Mito'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.80, [])
dir = [script_dir '\Datasets\Rab4A excel\SCA EEA1-Mito Rab4A\']; root = 'SCA-EEA1Mito'; 
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'Fixed', 0.85, [])

progressbar(1)

function [celllines, dir, root, mode] = DatasetDirSelection(script_dir)
        %Import App Information
        AppData = load('UIInputValues.mat');
        delete UIInputValues.mat

        imp_dir = AppData.imp_dir;
        exp_dir = AppData.exp_dir;
        root = AppData.root_name;
        celllines = AppData.node_string.';
        mode = AppData.mode;
        
        mkdir(strcat(exp_dir, '\IMARIS Data'))
        mkdir(strcat(exp_dir, '\MATLAB Data'))
        mkdir(strcat(exp_dir, '\Figures'))
        
        cd(imp_dir)
        for i = 1: length(celllines)
            [status, message] = copyfile(strcat(celllines(i),'*'), strcat(exp_dir, '\IMARIS Data'));
            if status == 1
                message
            end
        end
        cd(script_dir)
        
        dir = append(exp_dir,'\');



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
   
    if (import == 1)
        IMARISDataImport_02142023(celllines_color, celllines, dir, root, type, tp, pool, progress); cd(script_dir); 
    end

    progressbar('MainScript', root, 'Classification', '', '')
    
    if (rf == 1)
         MDDRStageIICode_03032023(celllines_color, celllines, dir, root, progress); cd(script_dir);
    end

    progressbar('MainScript', root, 'Exporting', '', '')
    if (export == 1)
        MATLABDataExport_02142023(dir, root, type, progress); cd(script_dir);
    end
    
end
