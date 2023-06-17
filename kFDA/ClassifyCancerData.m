clc
clear
close all

[Train,Test,All]   =  ReadData(0.85);
Model              =  KernelFDA(Train,Test,All);
VisualizeData(Model,Train,Test,All);
Model              =  FactorAnalysis(Model,Train);
