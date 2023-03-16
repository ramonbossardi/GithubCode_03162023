clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames')

import iosr.statistics.boxPlot
workspace_filename = "C:\Users\jagol\OneDrive\Documents\MATLAB\ML Scripts\Datasets\Fixed2D 6CL\ERC\MATLAB Data\Tf_Workspace.mat";


M = load(workspace_filename);

forest_dist = [M.forestCVErr_dist_npgdpg M.forestCVErr_dist M.forestCVErr_dist_opg M.forestCVErr_dist_npg...
    M.forestCVErr_dist_dpg M.forestCVErr_dist_opgnpg ...
    M.forestCVErr_dist_opgdpg];

figure('Name', 'Stage III Algorithm Comparison', 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.4 0.6]);

box = iosr.statistics.boxPlot({'NDPG', 'All', 'OPG', 'NPG', 'DPG', 'ONPG', 'ODPG'}, (1 - forest_dist) * 100);

box.symbolColor = [.01 .5 .32];
box.medianColor = [.01 .5 .32];

tpairs = nchoosek(1:10,2);

p_list = [];
pairs = {};
for i = 2:7
    sample1 = 1;
    sample2 = i;

    [h, p] = ttest2(forest_dist(:, sample1), forest_dist(:, sample2));

    p_list = [p_list p];
    pairs = [pairs {[sample1, sample2]}];
end

%H = sigstar(pairs, p_list);

ylabel('Accuracy (%)', "FontName", "Calibri", "FontSize", 14);
xlabel('Algorithm', "FontName", "Calibri", "FontSize", 14);
