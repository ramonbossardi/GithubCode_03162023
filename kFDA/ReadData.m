function [Train,Test,All] = ReadData(alpha)
% Change the filename of the comma delimited ('*.csv') file that needs to
% ber analyzed here:
Z                    =  csvread('3D_SCA_NDPG_Dataset_Data.csv');
K0                   =  4;
Train.x              =  Z(:,1);
Z                    =  Z(:,2:end);
Z0                   =  zscore(Z);
Ntrain               =  0;
Ntest                =  0;
All.x                =  [];
All.Z0               =  [];
All.K                =  zeros(1,K0);
for i=1:K0
    Index            =  find(Train.x(:,1)==i);
    X                =  Z0(Index,:);
    N                =  length(Index);   
    All.K(i)         =  N;
    All.Z0           =  [All.Z0;X];
    All.x            =  [All.x;i*ones(N,1)];
end
Ktrain               =  zeros(1,K0);
Ktest                =  zeros(1,K0);
Ztrain               =  [];
Ztest                =  [];
for i=1:K0
    Index            =  find(Train.x(:,end)==i);
    X                =  Z0(Index,:);
    N                =  length(Index); 
    Index_X          =  randsample(1:N,N);
    X                =  X(Index_X,:);
    Ktrain(i)      =  round( alpha * N );
    Ktest(i)       =  N - Ktrain(i);
    Ntrain           =  Ntrain + Ktrain(i);
    Ntest            =  Ntest  + Ktest(i);
    Ztrain           =  [Ztrain;X(1:Ktrain(i),:)];
    Ztest            =  [Ztest;X(Ktrain(i)+1:N,:)];
end
[Z0train,bar,std]    =  zscore(Ztrain);
Z0test               =  ( Ztest - ones(Ntest,1) * bar ) / diag(std);
xtrain               =  ones(Ntrain,1);
xtest                =  ones(Ntest,1);
k0                   =  1;
k1                   =  Ktrain(1);
k2                   =  1;
k3                   =  Ktest(1);
for i=1:length(Ktrain)
    xtrain(k0:k1,1)  =  i * ones(Ktrain(i),1);
    xtest(k2:k3,1)   =  i * ones(Ktest(i),1);
    if i<length(Ktrain)
        k0           =  k0 + Ktrain(i);
        k1           =  k1 + Ktrain(i+1);
        k2           =  k2 + Ktest(i);
        k3           =  k3 + Ktest(i+1);
    end
end
Train.Z0             =  Z0train;
Train.x              =  xtrain;
Train.K              =  Ktrain;
Test.Z0              =  Z0test;
Test.x               =  xtest;
Test.K               =  Ktest;