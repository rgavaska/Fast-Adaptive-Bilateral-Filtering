function [ Bf ] = fastABF( f,theta,filtertype,sigma_s,sigma_r,N )
%FASTABF Fast adaptive bilateral filter for grayscale images
% Input args:
%   f = m-by-n Input image (double type)
%   theta = m-by-n Centering image (double type)
%   sigma_s = Standard deviation of Gaussian spatial kernel
%   sigma_r = m-by-n matrix of pixelwise standard deviations of Gaussian range kernels (scale [0,255])
%   N = Degree of polynomial to fit
% Output args:
%   Bf = Adaptive bilateral filtered image (double type)

[fr,fc] = size(f);
if(isempty(theta))
    theta = f;
elseif(isscalar(theta))
    theta = theta*ones(fr,fc);
end

f = f/255;
theta = theta/255;
sigma_r = sigma_r/255;

% Compute local histogram range
if(isempty(filtertype) || strcmp(filtertype,'gaussian'))
    [Alpha,Beta] = MinMaxFilter(f,6*sigma_s+1);
elseif(strcmp(filtertype,'box'))
    [Alpha,Beta] = MinMaxFilter(f,2*sigma_s+1);
else
    error('Invalid filter type');
end
mask = (Alpha~=Beta);   % Mask for pixels with Alpha~=Beta
a = nan(fr,fc);
a(mask) = 1./(Beta(mask)-Alpha(mask));

% Compute polynomial coefficients at every pixel
C = fitPolynomial(f,sigma_s,N,Alpha,Beta,filtertype);

% Pre-compute integrals at every pixel
zero = 1;
t0 = (theta(mask)-Alpha(mask))./(Beta(mask)-Alpha(mask));
lambda = 1./(2*sigma_r(mask).*sigma_r(mask).*a(mask).*a(mask));
F = compInt(N+1,lambda,t0);

% Compute numerator and denominator
Num = zeros(nnz(mask),1);
Den = Num;
for k = 0:N
    Ck = C(:,zero+k);
    Num = Num + Ck.*F{zero+k+1};
    Den = Den + Ck.*F{zero+k};
end

% Undo shifting & scaling to get output (eq. 29 in paper)
Bf = nan(fr,fc);
Bf(mask) = Alpha(mask) + (Beta(mask)-Alpha(mask)).*Num./Den;
Bf(~mask) = f(~mask);
Bf = 255*Bf;

end

