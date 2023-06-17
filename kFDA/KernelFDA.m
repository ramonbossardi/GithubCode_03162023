function CM = KernelFDA(Train,Test,All)
options.KernelType            =  'Gaussian';
options.Regu                  =  1;
[regul,sigma]                 =  GetHyperParameters(Train,Test,options);
CM.alpha                      =  regul;
CM.sigma                      =  sigma;
Xtrain                        =  Train.Z0;
Xtest                         =  Test.Z0;
Xall                          =  All.Z0;
Ytrain                        =  Train.x';
Ytest                         =  Test.x';
Yall                          =  All.x';                         
Ntrain                        =  sum(Train.K);
Ntest                         =  sum(Test.K);
Nall                          =  sum(All.K);
options.ReguAlpha             =  regul;
options.t                     =  sigma;
[eigvector,eigvalue,Ktrain,n] =  kda_multi(options,Ytrain, Xtrain);
CM.n                          =  n;
[~, SortOrder]                =  sort(eigvalue,'descend');
CM.J                          =  eigvalue(SortOrder);
eigvector                     =  eigvector(:,SortOrder);
Ktest                         =  constructKernel_multi(Xtrain,Xtest,options);
Kall                          =  constructKernel_multi(Xtrain,Xall,options);
Ttrain                        =  Ktrain' * eigvector;
Ttest                         =  Ktest' * eigvector;
Tall                          =  Kall' * eigvector;
idx1                          =  Ytrain==1;
idx2                          =  Ytrain==2;
if CM.n>2
    idx3                      =  Ytrain==3;
    idx4                      =  Ytrain==4;
    if CM.n>4
        idx5                  =  Ytrain==5;
        idx6                  =  Ytrain==6;
        if CM.n>6
            idx7              =  Ytrain==7;
            idx8              =  Ytrain==8;
        end
    end
end
y1_mean                       =  mean(Ttrain(idx1,:));
y2_mean                       =  mean(Ttrain(idx2,:));
if CM.n >2
    y3_mean                   =  mean(Ttrain(idx3,:));
    y4_mean                   =  mean(Ttrain(idx4,:));
    if CM.n>4
        y5_mean               =  mean(Ttrain(idx5,:));
        y6_mean               =  mean(Ttrain(idx6,:));
        if CM.n>6
            y7_mean           =  mean(Ttrain(idx7,:));
            y8_mean           =  mean(Ttrain(idx8,:));
        end
    end
end
CMtrain                       =  zeros(CM.n,CM.n);
ypred                         =  zeros(size(Ytrain));
for i=1:Ntrain
    ttrain                    =  Ttrain(i,:);
    y                         =  Ytrain(i);
    y1                        =  norm(ttrain - y1_mean);
    y2                        =  norm(ttrain - y2_mean);
    if CM.n>2
        y3                    =  norm(ttrain - y3_mean);
        y4                    =  norm(ttrain - y4_mean);
        if CM.n>4
            y5                =  norm(ttrain - y5_mean);
            y6                =  norm(ttrain - y6_mean);
            if CM.n>6
                y7            =  norm(ttrain - y7_mean);
                y8            =  norm(ttrain - y8_mean);
            end
        end
    end
    if CM.n == 2
        ydist                 =  [y1 y2];
    elseif CM.n == 4
        ydist                 =  [y1 y2 y3 y4];
    elseif CM.n == 6
        ydist                 =  [y1 y2 y3 y4 y5 y6];
    elseif CM.n == 8
        ydist                 =  [y1 y2 y3 y4 y5 y6 y7 y8];
    end
    [~,ypred(i)]              =  min(ydist);
    CMtrain(y,ypred(i))       =  CMtrain(y,ypred(i)) + 1;
end
CMtest                        =  zeros(CM.n,CM.n);
A                             =  0;
B                             =  0;
C                             =  0;
D                             =  0;
for i=1:Ntrain-1
    for j=i+1:Ntrain
        if and(Ytrain(i) == Ytrain(j),ypred(i)==ypred(j))
            A                 = A + 1;
        elseif and(Ytrain(i) == Ytrain(j),ypred(i)~=ypred(j))
            B                 = B + 1;
        elseif and(Ytrain(i) ~= Ytrain(j),ypred(i) == ypred(j))
            C                 = C + 1;
        elseif and(Ytrain(i) ~= Ytrain(j),ypred(i) ~= ypred(j))
            D                 = D + 1;
        end
    end
end
fprintf('A = %d, B = %d, C = %d, D = %d\n',A,B,C,D);
JI                            =  A / ( A + B + C );
FMI                           =  A / ( sqrt((A+B)*(A+C)));
RI                            =  A / ( A + B + C + D );
temp                          =  (A+B)*(A+C) + (C+D)*(B+D);
numerator                     =  nchoosek(Ntrain,2)*(A+D) - temp;
denominator                   =  nchoosek(Ntrain,2)^2 - temp;
ARI                           =  numerator / denominator;
ACC                           =  sum(diag(CMtrain)) / sum(sum(CMtrain));
fprintf('ACC = %.3f, JI = %.3f, FMI = %.3f, RI = %.3f, ARI = %.3f\n',ACC,JI,FMI,RI,ARI);
e                             =  Ytrain - ypred;
RMSE                          =  sqrt( ( e * e' ) / Ntrain );
y0                            =  Ytrain - mean(Ytrain)*ones(1,Ntrain);
y0pred                        =  ypred - mean(Ytrain)*ones(1,Ntrain);
Q2                            =  ( e * e' ) / ( y0 * y0' );
r                             =  ( y0 * y0pred' ) / ( sqrt( y0 * y0' ) * sqrt( y0pred * y0pred' ) );
q2                            =  1 - r^2;
MAE                           =  sum(abs(Ytrain - ypred)) / Ntrain;
CM.q2train                    =  q2;
CM.Q2train                    =  Q2;
CM.RMSEtrain                  =  RMSE;
CM.MAEtrain                   =  MAE;
CM.Ttrain                     =  Ttrain;
CM.Ytrain                     =  Ytrain;
fprintf('RMSE = %.3f, MAE = %.3f, Q2 = %.3f, q2 = %.3f\n',RMSE,MAE,Q2,q2);
CM.YtrainPred                 =  ypred;
ypred                         =  zeros(size(Ytest));
for i=1:Ntest
    ttest                     =  Ttest(i,:);
    y                         =  Ytest(i);
    y1                        =  norm(ttest - y1_mean);
    y2                        =  norm(ttest - y2_mean);
    if CM.n>2
        y3                    =  norm(ttest - y3_mean);
        y4                    =  norm(ttest - y4_mean);
        if CM.n>4
            y5                =  norm(ttest - y5_mean);
            y6                =  norm(ttest - y6_mean);
            if CM.n>6
                y7            =  norm(ttest - y7_mean);
                y8            =  norm(ttest - y8_mean);
            end
        end
    end
    if CM.n == 2
        ydist        =  [y1 y2];
    elseif CM.n == 4
        ydist        =  [y1 y2 y3 y4];
    elseif CM.n == 6
        ydist        =  [y1 y2 y3 y4 y5 y6];
    elseif CM.n == 8
        ydist        =  [y1 y2 y3 y4 y5 y6 y7 y8];
    end       
    [~,ypred(i)]              =  min(ydist);
    CMtest(y,ypred(i))        =  CMtest(y,ypred(i)) + 1;
end
A                             =  0;
B                             =  0;
C                             =  0;
D                             =  0;
for i=1:Ntest-1
    for j=i+1:Ntest
        if and(Ytest(i) == Ytest(j),ypred(i)==ypred(j))
            A                 =  A + 1;
        elseif and(Ytest(i) == Ytest(j),ypred(i)~=ypred(j))
            B                 =  B + 1;
        elseif and(Ytest(i) ~= Ytest(j),ypred(i) == ypred(j))
            C                 =  C + 1;
        elseif and(Ytest(i) ~= Ytest(j),ypred(i) ~= ypred(j))
            D                 =  D + 1;
        end
    end
end
fprintf('A = %d, B = %d, C = %d, D = %d\n',A,B,C,D);
JI                            =  A / ( A + B + C );
FMI                           =  A / ( sqrt((A+B)*(A+C)));
RI                            =  A / ( A + B + C + D );
temp                          =  (A+B)*(A+C) + (C+D)*(B+D);
numerator                     =  nchoosek(Ntest,2)*(A+D) - temp;
denominator                   =  nchoosek(Ntest,2)^2 - temp;
ARI                           =  numerator / denominator;
ACC                           =  sum(diag(CMtest)) / sum(sum(CMtest));
CM.ACCtest                    =  ACC;
CM.JItest                     =  JI;
CM.RItest                     =  RI;
CM.FMItest                    =  FMI;
CM.ARItest                    =  ARI;
fprintf('ACC = %.3f, JI = %.3f, FMI = %.3f, RI = %.3f, ARI = %.3f\n',ACC,JI,FMI,RI,ARI);
e                             =  Ytest - ypred;
RMSE                          =  sqrt( ( e * e' ) / Ntest );
y0                            =  Ytest - mean(Ytrain)*ones(1,Ntest);
y0pred                        =  ypred - mean(Ytrain)*ones(1,Ntest);
Q2                            =  ( e * e' ) / ( y0 * y0' );
r                             =  ( y0 * y0pred' ) / ( sqrt( y0 * y0' ) * sqrt( y0pred * y0pred' ) );
q2                            =  1 - r^2;
MAE                           =  sum(abs(Ytest - ypred)) / Ntrain;
CM.q2test                     =  q2;
CM.Q2test                     =  Q2;
CM.RMSEtest                   =  RMSE;
CM.MAEtest                    =  MAE;
fprintf('RMSE = %.3f, MAE = %.3f, Q2 = %.3f, q2 = %.3f\n',RMSE,MAE,Q2,q2);
CM.CMtrain                    =  CMtrain;
CM.CMtest                     =  CMtest;
CM.Ttest                      =  Ttest;
CM.Ytest                      =  Ytest;
CM.YtestPred                  =  ypred;
ypred                         =  zeros(size(Yall));
CMall                         =  zeros(CM.n,CM.n);
for i=1:Nall
    tall                      =  Tall(i,:);
    y                         =  Yall(i);
    y1                        =  norm(tall - y1_mean);
    y2                        =  norm(tall - y2_mean);
    if CM.n > 2
        y3                    =  norm(tall - y3_mean);
        y4                    =  norm(tall - y4_mean);
        if CM.n > 4
            y5                =  norm(tall - y5_mean);
            y6                =  norm(tall - y6_mean);
            if CM.n > 6
                y7            =  norm(tall - y7_mean);
                y8            =  norm(tall - y8_mean);
            end
        end
    end
    if CM.n == 2
        ydist                 =  [y1 y2];
    elseif CM.n == 4
        ydist                 =  [y1 y2 y3 y4];
    elseif CM.n == 6
        ydist                 =  [y1 y2 y3 y4 y5 y6];
    elseif CM.n == 8
        ydist                 =  [y1 y2 y3 y4 y5 y6 y7 y8];
    end
    [~,ypred(i)]              =  min(ydist);
    CMall(y,ypred(i))         =  CMall(y,ypred(i)) + 1;
end
A                             =  0;
B                             =  0;
C                             =  0;
D                             =  0;
for i=1:Nall-1
    for j=i+1:Nall
        if and(Yall(i) == Yall(j),ypred(i)==ypred(j))
            A                 =  A + 1;
        elseif and(Yall(i) == Yall(j),ypred(i)~=ypred(j))
            B                 =  B + 1;
        elseif and(Yall(i) ~= Yall(j),ypred(i) == ypred(j))
            C                 =  C + 1;
        elseif and(Yall(i) ~= Yall(j),ypred(i) ~= ypred(j))
            D                 =  D + 1;
        end
    end
end
fprintf('A = %d, B = %d, C = %d, D = %d\n',A,B,C,D);
JI                            =  A / ( A + B + C );
FMI                           =  A / ( sqrt((A+B)*(A+C)));
RI                            =  A / ( A + B + C + D );
temp                          =  (A+B)*(A+C) + (C+D)*(B+D);
numerator                     =  nchoosek(Nall,2)*(A+D) - temp;
denominator                   =  nchoosek(Nall,2)^2 - temp;
ARI                           =  numerator / denominator;
ACC                           =  sum(diag(CMall)) / sum(sum(CMall));
CM.ACCall                     =  ACC;
CM.JIall                      =  JI;
CM.RIall                      =  RI;
CM.FMIall                     =  FMI;
CM.ARIall                     =  ARI;
fprintf('ACC = %.3f, JI = %.3f, FMI = %.3f, RI = %.3f, ARI = %.3f\n',ACC,JI,FMI,RI,ARI);
e                             =  Yall - ypred;
RMSE                          =  sqrt( ( e * e' ) / Nall );
y0                            =  Yall - mean(Yall)*ones(1,Nall);
y0pred                        =  ypred - mean(Yall)*ones(1,Nall);
Q2                            =  ( e * e' ) / ( y0 * y0' );
r                             =  ( y0 * y0pred' ) / ( sqrt( y0 * y0' ) * sqrt( y0pred * y0pred' ) );
q2                            =  1 - r^2;
MAE                           =  sum(abs(Yall - ypred)) / Nall;
CM.q2all                      =  q2;
CM.Q2all                      =  Q2;
CM.RMSEall                    =  RMSE;
CM.MAEall                     =  MAE;
fprintf('RMSE = %.3f, MAE = %.3f, Q2 = %.3f, q2 = %.3f\n',RMSE,MAE,Q2,q2);
CM.CMall                      =  CMall;
CM.Tall                       =  Tall;
CM.Yall                       =  Yall;
CM.YallPred                   =  ypred;
CM.Eigenvectors               =  eigvector; 