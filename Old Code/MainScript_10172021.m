clear
clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

script_dir = cd;
celllines_color = ''; 
progressbar('MainScript', '', '', '', '')


%Original 2D Datasets:
celllines = ["MCF10A", "MDA231", "MDA436", "MDA468", "AU565", "T47D"];
%{
%EEC:
dir = [script_dir '\Original 2D Datasets\2D 3CL\EEC\'];
root = 'RandomForest_10172021_2D3CLEEC';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, '', 0)
%Mito:
dir = [script_dir '\Original 2D Datasets\2D 3CL\Mito\'];
root = 'RandomForest_10172021_2D3CLMito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, '', 0)
%ERC:
dir = [script_dir '\Original 2D Datasets\2D 6CL\ERC\'];
root = 'RandomForest_06262021_2D6CLERC';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.05)
%Mito:
dir = [script_dir '\Original 2D Datasets\2D 6CL\Mito\'];
root = 'RandomForest_06262021_2D6CLMito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.1)
%}

%EECERC Inter:
dir = [script_dir '\Datasets\EECERCInt 6CL\'];
root = 'RandomForest_06262021_2D6CL_EECERCInt';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.15)
%EECMito Inter:
dir = [script_dir '\Datasets\ERCMitoInt 6CL\'];
root = 'RandomForest_06262021_2D6CL_EECMitoInt';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.20)
%ERCMito Inter:
dir = [script_dir '\Datasets\EECMitoInt 6CL\'];
root = 'RandomForest_06262021_2D6CL_ERCMitoInt';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.25)

%{
%Fixed 2D+3D Datasets 1
%2D 4CL Mito
celllines = ["AU565", "MCF10A", "MDA231", "T47D"];
dir = [script_dir '\Fixed 2D+3D Datasets 1\2D 4CL\Mito\'];
root = 'RandomForest_06262021_2D4CLMito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.30)

%3D 4CL Mito
celllines = ["AU5653DM", "MCF10A3DM", "MDA2313DM", "T47D3DM"];
dir = [script_dir '\Fixed 2D+3D Datasets 1\3D 4CL\Mito\'];
root = 'RandomForest_06262021_3D4CLMito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.35)
%3D 4CL Cell+Mito
dir = [script_dir '\Fixed 2D+3D Datasets 1\3D 4CL\Cell+Nuc\'];
root = 'RandomForest_06262021_3D4CLCellNuc';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'cellnuc', 0.4)


%2D+3D 4CL Mito
celllines = ["AU565", "MCF10A", "MDA231", "T47D", "AU5653DM", "MCF10A3DM", "MDA2313DM", "T47D3DM"];
dir = [script_dir '\Fixed 2D+3D Datasets 1\2D+3D 4CL\Mito\'];
root = 'RandomForest_06262021_2D3D4CLMito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.45)
%2D+3D AU565 Mito
celllines = ["AU565", "AU5653DM"];
dir = [script_dir '\Fixed 2D+3D Datasets 1\2D+3D AU565\Mito\'];
root = 'RandomForest_06262021_2D3DAU565Mito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.50)
%2D+3D MCF10A Mito
celllines = ["MCF10A", "MCF10A3DM"];
dir = [script_dir '\Fixed 2D+3D Datasets 1\2D+3D MCF10A\Mito\'];
root = 'RandomForest_06262021_2D3DMCF10AMito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.55)
%2D+3D MDA231 Mito
celllines = ["MDA231", "MDA2313DM"];
dir = [script_dir '\Fixed 2D+3D Datasets 1\2D+3D MDA231\Mito\'];
root = 'RandomForest_06262021_2D3DMDA231Mito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.6)
%2D+3D T47D Mito
celllines = ["T47D", "T47D3DM"];
dir = [script_dir '\Fixed 2D+3D Datasets 1\2D+3D T47D\Mito\'];
root = 'RandomForest_06262021_2D3DT47DMito';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.65)

%Fixed 2D+3D Datasets 2
%3D 2 CL
temp_dir = [script_dir '\Fixed 2D+3D Datasets 2\3D 2 CL\'];
celllines = ["MCF10A3DM", "MDA2313DM"];
temp_root = 'RandomForest_06262021_3D2CL';
%ERC
dir = [temp_dir 'ERC\'];
root = [temp_root 'ERC'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.70)
%Mito
dir = [temp_dir 'Mito\'];
root = [temp_root 'Mito'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.72)
%ERCMito
dir = [temp_dir 'MitoERC Interaction\'];
root = [temp_root 'ERCMitoInter'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.74)

%2D+3D 2 CL
temp_dir = [script_dir '\Fixed 2D+3D Datasets 2\2D+3D 2 CL\'];
celllines = ["MCF10A", "MDA231", "MCF10A3DM", "MDA2313DM"];
temp_root = 'RandomForest_06262021_2D3D2CL';
%ERC
dir = [temp_dir 'ERC\'];
root = [temp_root 'ERC'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.76)
%Mito
dir = [temp_dir 'Mito\'];
root = [temp_root 'Mito'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.78)
%ERCMito
dir = [temp_dir 'MitoERC Interaction\'];
root = [temp_root 'ERCMitoInter'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.80)

%2D+3D MCF10A
temp_dir = [script_dir '\Fixed 2D+3D Datasets 2\2D+3D MCF10A\'];
celllines = ["MCF10A", "MCF10A3DM"];
temp_root = 'RandomForest_06262021_2D3DMCF10A';
%ERC
dir = [temp_dir 'ERC\'];
root = [temp_root 'ERC'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.82)
%Mito
dir = [temp_dir 'Mito\'];
root = [temp_root 'Mito'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.84)
%ERCMito
dir = [temp_dir 'MitoERC Interaction\'];
root = [temp_root 'ERCMitoInter'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.86)

%2D+3D MDA231
temp_dir = [script_dir '\Fixed 2D+3D Datasets 2\2D+3D MDA231\'];
celllines = ["MDA231", "MDA2313DM"];
temp_root = 'RandomForest_06262021_2D3DMDA231';
%ERC
dir = [temp_dir 'ERC\'];
root = [temp_root 'ERC'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.88)
%Mito
dir = [temp_dir 'Mito\'];
root = [temp_root 'Mito'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.90)
%ERCMito
dir = [temp_dir 'MitoERC Interaction\'];
root = [temp_root 'ERCMitoInter'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, ' ', 0.92)


%Live 2D Datasets
%5CL
temp_dir = [script_dir '\Live 2D Datasets\5CL\'];
celllines = ["MCFWT", "MDAKO", "MDAWT", "T47DKO", "T47DWT"];
temp_root = 'RandomForest_06262021_Live2D5CL';
%EEC
dir = [temp_dir 'EEC\'];
root = [temp_root 'EEC'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'live', 0.82)
%Mito
dir = [temp_dir 'Mito\'];
root = [temp_root 'Mito'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'live', 0.82)
%EECMito
dir = [temp_dir 'MitoEEC Interaction\'];
root = [temp_root 'EECMito'];
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'live', 0.82)
%Cell+Nuc
%}


progressbar(1)

function CompleteRFScript(celllines_color, celllines, dir, root, script_dir, specialcase, progress)
    if strcmp(specialcase, 'noimport')
        progressbar('MainScript', root, 'Classification', '', '')
        progressbar(progress, 0)
        RandomForest_10172021(celllines_color, celllines, dir, root); cd(script_dir);
        progressbar('MainScript', root, 'Exportation', '', '')
        progressbar(progress, .5)
        MATLABDataExport_06232021(dir, root); cd(script_dir);
    elseif strcmp(specialcase, 'exportonly')
        progressbar('MainScript', root, 'Exportation', '', '')
        progressbar(progress, 0)
        MATLABDataExport_06232021(dir, root); cd(script_dir);
    elseif strcmp(specialcase, 'cellnuc')
        progressbar('MainScript', root, 'Importation', '', '')
        progressbar(progress, 0)
        IMARISDataImport_06252021_CellNucEdit(celllines_color, celllines, dir, root); cd(script_dir); 
        progressbar('MainScript', root, 'Classification', '', '')
        progressbar(progress, .33)
        RandomForest_06252021_CellNucEdit(celllines_color, celllines, dir, root); cd(script_dir);
        progressbar('MainScript', root, 'Exportation', '', '')
        progressbar(progress, .67)
        MATLABDataExport_06232021_CellNucEdit(dir, root); cd(script_dir);
    elseif strcmp(specialcase, 'live')
        progressbar('MainScript', root, 'Importation', '', '')
        progressbar(progress, 0)
        IMARISDataImport_06252021_LiveTime5Edit(celllines_color, celllines, dir, root); cd(script_dir); 
        progressbar('MainScript', root, 'Classification', '', '')
        progressbar(progress, .33)
        RandomForest_10172021(celllines_color, celllines, dir, root); cd(script_dir);
        progressbar('MainScript', root, 'Exportation', '', '')
        progressbar(progress, .67)
        MATLABDataExport_06232021(dir, root); cd(script_dir);
    else
        progressbar('MainScript', root, 'Importation', '', '')
        progressbar(progress, 0)
        IMARISDataImport_06252021(celllines_color, celllines, dir, root); cd(script_dir); 
        progressbar('MainScript', root, 'Classification', '', '')
        progressbar(progress, .33)
        RandomForest_12212022_ROC(celllines_color, celllines, dir, root); cd(script_dir);
        progressbar('MainScript', root, 'Exportation', '', '')
        progressbar(progress, .67)
        MATLABDataExport_06232021(dir, root); cd(script_dir);
    end
    
end
