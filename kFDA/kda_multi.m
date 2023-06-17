function [eigvector,eigvalue,K,nClass] = kda_multi(options,gnd,data)
K                     =  constructKernel_multi(data,[],options);
clear data;
%Initialization
nSmp                  =  size(K,1);
% Identify the number of unique labels 1 and -1 in our case
classLabel            =  unique(gnd);
nClass                =  length(classLabel);
Dim                   =  nClass - 1;
sumK                  =  sum(K,2);
% Mean centering the kernel matrices
H                     =  repmat(sumK./nSmp,1,nSmp);
K                     =  K - H - H' + sum(sumK)/(nSmp^2);
K                     =  max(K,K');
clear H;
% Allocating memory space for the sample mean vectors in the feature space
Hb                    =  zeros(nClass,nSmp);
for i = 1:nClass
    index             =  find(gnd==classLabel(i));
    classMean         =  mean(K(index,:),1);
    Hb(i,:)           =  sqrt(length(index))*classMean;
end
% Defining the matrices G and H
H                     =  Hb' * Hb ;
G                     =  K * K;
% Adding the regularization term
for i=1:size(G,1)
    G(i,i)            =  G(i,i) + options.ReguAlpha;
end

option                =  struct('disp',0);
% Eigendecomposition to determine projection directions in the feature
% space
[eigvector, eigvalue] =  eigs(H,G,Dim,'la',option);
eigvalue              =  diag(eigvalue);
