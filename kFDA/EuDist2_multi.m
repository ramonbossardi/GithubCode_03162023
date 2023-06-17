function D = EuDist2_multi(fea_a,fea_b)
if (~exist('fea_b','var')) || isempty(fea_b)
    aa = sum(fea_a.*fea_a,2);
    ab = fea_a * fea_a'; 
    D  = aa + aa' - 2*ab;
else
    aa = sum(fea_a.*fea_a,2);
    bb = sum(fea_b.*fea_b,2);     
    ab = fea_a * fea_b';
    D  = aa + bb' - 2*ab;
end