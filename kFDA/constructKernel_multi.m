function K = constructKernel_multi(fea_a,fea_b,options)
% Determining phi( x_i^(0) , x_j^(0) )
D = EuDist2_multi(fea_a,fea_b);
K = exp( - D / ( 2 * options.t^2 ) );