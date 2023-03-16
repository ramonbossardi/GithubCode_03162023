clear
clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

script_dir = cd;
celllines_color = ''; 
progressbar('MainScript', '', '', '', '')


%Original 2D Datasets:
celllines = ["AU565", "MCF10A", "MDA231", "MDA436", "MDA468", "T47D"];
%EEC:
dir = [script_dir '\Original 2D Datasets\2D 6CL\EEC\'];
root = 'RandomForest_06262021_2D6CLEEC';
CompleteRFScript(celllines_color, celllines, dir, root, script_dir, 'noimport', 0)

progressbar(1)

function CompleteRFScript(celllines_color, celllines, dir, root, script_dir, specialcase, progress)
    if strcmp(specialcase, 'noimport')
        progressbar('MainScript', root, 'Classification', '', '')
        progressbar(progress, 0)
        RandomForest_10132021_ROCFix(celllines_color, celllines, dir, root); cd(script_dir);
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
        RandomForest_06252021(celllines_color, celllines, dir, root); cd(script_dir);
        progressbar('MainScript', root, 'Exportation', '', '')
        progressbar(progress, .67)
        MATLABDataExport_06232021(dir, root); cd(script_dir);
    else
        progressbar('MainScript', root, 'Importation', '', '')
        progressbar(progress, 0)
        IMARISDataImport_06252021(celllines_color, celllines, dir, root); cd(script_dir); 
        progressbar('MainScript', root, 'Classification', '', '')
        progressbar(progress, .33)
        RandomForest_10132021_ROCFix(celllines_color, celllines, dir, root); cd(script_dir);
        progressbar('MainScript', root, 'Exportation', '', '')
        progressbar(progress, .67)
        MATLABDataExport_06232021(dir, root); cd(script_dir);
    end
    
end
