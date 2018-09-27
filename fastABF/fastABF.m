function [ g_hat ] = fastABF( f,rho,sigma_r,theta,N,filtertype )
%FASTABF Fast adaptive bilateral filter for grayscale images
% 
% g_hat = fastABF(f,rho,sigma_r) filters the input image f using the
% Gaussian spatial kernel parameter rho and pixelwise Gaussian range kernel
% parameters sigma_r. The centering parameters theta are equal to f by
% default.
% 
% g_hat = fastABF(f,rho,sigma_r,theta) filters the input image f using the
% Gaussian spatial kernel parameter rho, pixelwise Gaussian range kernel
% parameters sigma_r, and pixelwise centering parameters theta (see paper
% for details).
% 
% g_hat = fastABF(f,rho,sigma_r,theta,N) performs the same operation as
% above, with N being the degree of the polynomial (N=5 by default).
% 
% g_hat = fastABF(f,rho,sigma_r,theta,N,filtertype) performs the same
% operation as above with the spatial filter type specified by the final
% argument, which can be either 'gaussian' (default) or 'box'. All results
% in the paper are using the Gaussian spatial kernel. If filtertype is
% 'box', then rho specifies the half-width of the box kernel
% (kernel length = 2*rho+1).
% 
% Input arguments:
%   f = m-by-n Input image (grayscale, double type)
%   rho = Standard deviation of Gaussian spatial kernel OR radius of box
%       kernel
%   sigma_r = m-by-n matrix of pixelwise standard deviations of Gaussian 
%       range kernels (scale [0,255])
%   theta = m-by-n Centering image (double type)
%   N = Degree of polynomial to fit
%   filtertype = Spatial filter type, 'gaussian' (default) or 'box'
% Output arguments:
%   g_hat = Output image using the fast algorithm
% 
% Ref. R. G. Gavaskar and K. N. Chaudhury, "Fast Adaptive Bilateral
% Filtering", to be published in IEEE Transactions on Image Processing.
% 

if(~exist('theta','var') || isempty(theta))
    theta = f;
end
if(~exist('N','var') || isempty(N))
    N = 5;
end
if(~exist('filtertype','var') || isempty(filtertype))
    filtertype = 'gaussian';
end

[rr,cc] = size(f);
f = f/255;
theta = theta/255;
sigma_r = sigma_r/255;

% Compute local histogram range
if(strcmp(filtertype,'gaussian'))
    [Alpha,Beta] = MinMaxFilter(f,6*rho+1);
elseif(strcmp(filtertype,'box'))
    [Alpha,Beta] = MinMaxFilter(f,2*rho+1);
else
    error('Invalid filter type');
end
mask = (Alpha~=Beta);   % Mask for pixels with Alpha~=Beta
a = nan(rr,cc);
a(mask) = 1./(Beta(mask)-Alpha(mask));

% Compute polynomial coefficients at every pixel
C = fitPolynomial(f,rho,N,Alpha,Beta,filtertype);

% Pre-compute integrals at every pixel
zero = 1;
t0 = (theta(mask)-Alpha(mask))./(Beta(mask)-Alpha(mask));
lambda = 1./(2*sigma_r(mask).*sigma_r(mask).*a(mask).*a(mask));
I = compInt(N+1,lambda,t0);

% Compute numerator and denominator
Num = zeros(nnz(mask),1);
Den = Num;
for k = 0:N
    Ck = C(:,zero+k);
    Num = Num + Ck.*I{zero+k+1};
    Den = Den + Ck.*I{zero+k};
end

% Undo shifting & scaling to get output (eq. 29 in paper)
g_hat = nan(rr,cc);
g_hat(mask) = Alpha(mask) + (Beta(mask)-Alpha(mask)).*Num./Den;
g_hat(~mask) = f(~mask);
g_hat = 255*g_hat;

end

