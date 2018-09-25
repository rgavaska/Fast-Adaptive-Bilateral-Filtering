function [ g ] = sharpen_adaptive( f,sigma_s,sigma_r )
%SHARPEN_ADAPTIVE
% Sharpen image (after texture smoothing)
% f = Input image (double)
% sigma_s = Standard deviation of Gaussian spatial kernel
% sigma_r = Pixelwise standard deviations of Gaussian range kernels

if(size(f,3)==3)
    fgray = double(rgb2gray(uint8(f)));
end
if(isscalar(sigma_r))
    sigma_r = sigma_r*ones(size(fgray));
end
f_filt = imfilter(fgray,ones(6*sigma_s+1)/((6*sigma_s+1)^2),'symmetric');
zeta = fgray - f_filt;

g = nan(size(f));
for k = 1:size(f,3)
    g(:,:,k) = fastABF(f(:,:,k),f(:,:,k)+zeta,'gaussian',sigma_s,sigma_r,5);
end

end

