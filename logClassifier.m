function [ zeta,sigma_r ] = logClassifier( f,rho,sigma_interval )
%LOGCLASSIFIER
% Simulate LoG classifier to set pixelwise sigma values
% Idea based on the following paper:
% B. Zhang and J. P. Allebach, "Adaptive bilateral filter for sharpness
% enhancement and noise removal," IEEE Transactions on Image Processing,
% vol. 17, no. 5, pp. 664–678, 2008.
% 
% Input arguments:
%   f = Input image
%   rho = Gaussian spatial kernel parameter
%   sigma_interval = Interval which should contain sigma values
% Output arguments:
%   zeta = Offset image (see above paper for explanation)
%   sigma_r = Pixelwise range kernel parameters, set using LoG classifier

h_log = fspecial('log',9,9/6);
f_log = imfilter(f,h_log,'symmetric');  % LoG filter the image
L = zeros(size(f));
L(f_log>60) = 60;
L(f_log<-60) = -60;
mask = (f_log>-60 & f_log<60);
L(mask) = f_log(mask);
L = round(L*2)/2;

% Map LoG class values to sigma_r values
sigma_r = linearMap(abs(L),[0,max(abs(L(:)))],[sigma_interval(2),sigma_interval(1)]);

% Compute offset image
fbar = imfilter(f,ones(6*rho+1)/((6*rho+1)^2),'symmetric');
zeta = f - fbar;    % Offset image

end

