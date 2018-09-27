function [ Bf ] = abf_bruteforce( f,rho,sigma_r,theta,filtertype )
%ABF_BRUTEFORCE Brute-force adaptive bilateral filter
% Input args:
%   f = m-by-n Input image (double)
%   rho = Standard deviation of Gaussian spatial kernel OR radius of box
%   kernel
%   sigma_r = m-by-n Mmatrix of standard deviations of Gaussian range kernels
%   theta = m-by-n Centering image (default: input image)
%   filtertype = Spatial filter type, 'gaussian' (default) or 'box'
% Use [] for default parameters
% Output args:
%   Bf = Output image
%   runtime = Total implementation time

if(~exist('theta','var') || isempty(theta))
    theta = f;
end
if(~exist('filtertype','var') || isempty(filtertype))
    filtertype = 'gaussian';
end

[fr, fc] = size(f);
if(strcmp(filtertype,'gaussian'))
    rad = 3*rho;
elseif(strcmp(filtertype,'box'))
    rad = rho;
end

f = padarray(f,[rad, rad, 0],'symmetric');  % Pad image
f = double(f);

% Spatial kernel
if(strcmp(filtertype,'gaussian'))
    omega = fspecial('gaussian',2*rad+1,rho);
elseif(strcmp(filtertype,'box'))
    omega = ones(2*rad+1);
end

W = zeros([fr,fc]);
Z = zeros([fr,fc]);
for j1 = rad+1:rad+fr
    for j2 = rad+1:rad+fc
        nb = f(j1-rad:j1+rad,j2-rad:j2+rad);
        r_arg = (nb - theta(j1-rad,j2-rad)).^2;
        rker = exp(-0.5*r_arg/(sigma_r(j1-rad,j2-rad)^2));
        W(j1-rad,j2-rad) = sum(sum(omega .* rker .* nb));
        Z(j1-rad,j2-rad) = sum(sum(omega .* rker));
    end
end
Bf = W ./ Z;

end
