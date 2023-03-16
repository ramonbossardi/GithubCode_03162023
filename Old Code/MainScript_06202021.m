clear
clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

script_dir = cd;
celllines_color = ''; 

%2D_6Obj_6CL: 2D, Six object Datasets, Six Celllines
celllines = ["AU565", "MCF10A", "MDA231", "MDA436", "MDA468", "T47D"];
dir = [script_dir '\2D 6Obj 6CL\'];
root = 'RandomForest_06202021_2D6Obj6CL';
IMARISDataImport_06152021(celllines_color, celllines, dir, root); cd(script_dir);
RandomForest_06202021(celllines_color, celllines, dir, root); cd(script_dir);
MATLABDataExport_06202021(dir, root); cd(script_dir);




celllines = ["AU565", "MCF10A", "MDA231", "T47D", "AU5653DM", "MCF10A3DM", "MDA2313DM", "T47D3DM"];
dir = [script_dir '\Combined 2D-3D\'];
root = 'RandomForest_06172021_Combined2D3D';
%IMARISDataImport_06152021(celllines_color, celllines, dir, root); cd(script_dir);
%RandomForest_06152021(celllines_color, celllines, dir, root); cd(script_dir);
%MATLABDataExport_06162021(dir, root); cd(script_dir);

celllines = ["AU5653DM", "MCF10A3DM", "MDA2313DM", "T47D3DM"];
dir = [script_dir '\56 Param Cell-Nuc\'];
root = 'RandomForest_06172021_CellNuc';
IMARISDataImport_06172021_CellNucEdit(celllines_color, celllines, dir, root); cd(script_dir);


load train.mat
sound(y, 2*Fs);