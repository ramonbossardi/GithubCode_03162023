function Model = FactorAnalysis(Model,Train)
options.KernelType            =  'Gaussian';
options.Regu                  =  1;
options.ReguAlpha             =  Model.alpha;
options.t                     =  Model.sigma;
Xtrain                        =  Train.Z0;
excitation                    =  randn(1000,1);
VAR                           =  zeros(Model.n-1,size(Train.Z0,2));
for i=1:Model.n-1
    for j=1:size(Train.Z0,2)
        X                     =  zeros(1000,size(Train.Z0,2));
        X(:,j)                =  excitation;
        K                     =  constructKernel_multi(Xtrain,X,options);
        T                     =  K' * Model.Eigenvectors(:,i);
        VAR(i,j)              =  std(T);
    end
    VAR(i,:)                  =  8 * VAR(i,:) / max(VAR(i,:));
    figure, bar(VAR(i,:),'w')
end
Model.VAR                     =  VAR;
Z = [(1:size(Train.Z0,2))' VAR'];
csvwrite('8Class_18Variables_Contributions.csv',Z)