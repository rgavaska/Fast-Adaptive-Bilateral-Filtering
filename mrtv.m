function [ M ] = mrtv( I,k )
%Normalized MRTV
% Idea based on the following paper:
% H. Cho, H. Lee, H. Kang, and S. Lee, "Bilateral texture filtering," ACM
% Transactions on Graphics, vol. 33, no. 4, p. 128, 2014.
% 
% Input arguments:
%   I = Input image (double)
%   k = Window length
% Output arguments:
%   M = MRTV (values normalized between 0 and 1)

if(size(I,3)==3)
    I = double(rgb2gray(uint8(I)));
end

I = imfilter(I,ones(5)/25,'symmetric');

[Imin,Imax] = MinMaxFilter(double(I),k);
Delta = Imax - Imin;

% Compute MRTV
[gradI,~] = imgradient(I,'centralDifference');
[~,num] = MinMaxFilter(gradI,k);
den = imfilter(gradI,ones(k),'symmetric');
M = Delta.*num./(den + 1e-9);
M(den==0) = 0;
M = M/max(M(:));

end

