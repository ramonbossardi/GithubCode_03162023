function [alpha_opt,gamma_opt]        = GetHyperParameters(Train,Test,options)
Xtrain                                = Train.Z0;
Xtest                                 = Test.Z0;
Ytrain                                = Train.x';
Ytest                                 = Test.x';
Ntest                                 = sum(Test.K);
alpha_range                           = 0.00001:0.00001:0.00001;
sigma_range                           = 1.2:0.05:1.9;
i1                                    = 0;
J                                     = zeros(length(alpha_range),length(sigma_range));
for alpha = alpha_range
    j1                                = 0;
    i1                                = i1 + 1;
    for sigma = sigma_range
        j1                            = j1 + 1;        
        options.ReguAlpha             = alpha;
        options.t                     = sigma;
        [eigvector,eigvalue,Ktrain,n] = kda_multi(options,Ytrain, Xtrain);
        [~, SortOrder]                = sort(eigvalue,'descend');
        eigvector                     = eigvector(:,SortOrder);
        Ktest                         = constructKernel_multi(Xtrain,Xtest,options);
        Ttrain                        = Ktrain' * eigvector;
        Ttest                         = Ktest' * eigvector;
        
        idx1                          = Ytrain==1;
        idx2                          = Ytrain==2;
        if n>2
            idx3                      = Ytrain==3;
            idx4                      = Ytrain==4;
            if n>4
                idx5                  = Ytrain==5;
                idx6                  = Ytrain==6;
                if n>6
                    idx7              = Ytrain==7;
                    idx8              = Ytrain==8;
                end
            end
        end
        y1_mean                       = mean(Ttrain(idx1,:));
        y2_mean                       = mean(Ttrain(idx2,:));
        if n>2
            y3_mean                   = mean(Ttrain(idx3,:));
            y4_mean                   = mean(Ttrain(idx4,:));
            if n>4
                y5_mean               = mean(Ttrain(idx5,:));
                y6_mean               = mean(Ttrain(idx6,:));
                if n>6
                    y7_mean           = mean(Ttrain(idx7,:));
                    y8_mean           = mean(Ttrain(idx8,:));
                end
            end   
        end
        for i=1:Ntest
            ttest                     = Ttest(i,:);
            y                         = Ytest(i);
            y1                        = norm(ttest - y1_mean);
            y2                        = norm(ttest - y2_mean);
            if n>2
                y3                    = norm(ttest - y3_mean);
                y4                    = norm(ttest - y4_mean);
                if n>4
                    y5                = norm(ttest - y5_mean);
                    y6                = norm(ttest - y6_mean);
                    if n>6
                        y7            = norm(ttest - y7_mean);
                        y8            = norm(ttest - y8_mean);
                    end
                end
            end
            if n==2
                ydist                 = [y1 y2];
            elseif n==4
                ydist                 = [y1 y2 y3 y4];
            elseif n==6
                ydist                 = [y1 y2 y3 y4 y5 y6];
            elseif n==8
                ydist                 = [y1 y2 y3 y4 y5 y6 y7 y8];
            end
            [~,ypred]                 = min(ydist);
            if (y==ypred) 
                J(i1,j1)              = J(i1,j1) + 1;
            end
        end
        fprintf('alpha = %.6f, sigma = %.2f; accuracy = %.4f\n',alpha,sigma,J(i1,j1)/Ntest);
    end
end
[~,col]                               = max(J(:));
[I_row, I_col]                        = ind2sub(size(J),col);
alpha_opt                             = alpha_range(I_row);
gamma_opt                             = sigma_range(I_col);
fprintf('\n\nalpha: %f sigma: %f\n',alpha_opt,gamma_opt);
fprintf('J: %d\n',max(max(J)));
% mesh(sigma_range, alpha_range,J)
% xlabel('sigma')
% ylabel('alpha')
% zlabel('J')