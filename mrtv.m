function [ M ] = mrtv( I,k )
%Normalized MRTV
% I = Input image (double)
% k = Window length
% M = MRTV

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

