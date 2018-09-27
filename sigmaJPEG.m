function [ sigma_r ] = sigmaJPEG( f,sigma_min,k0 )
%SIGMAJPEG
% Compute pixelwise sigma values for deblocking JPEG image
% Idea based on the following paper:
% M. Zhang and B. K. Gunturk, "Compression artifact reduction with
% adaptive bilateral filtering," Proc. SPIE Visual Communications and
% Image Processing, vol. 7257, 2009.
% 
% Input arguments:
%   f = Input image containing blocking artifatcs
%   sigma_min = Minimum value of sigma
%   k0 = Amplification factor (see above paper for details)
% Output arguments:
%   sigma_r = Pixelwise range kernel parameters

[M,N] = size(f);

[bmask,vmask,hmask,cornermask,centermask] = edgeMask(M,N);
[R,C] = find(bmask);

% Find discontinuities at block boundaries
bV = imfilter(f,[-1,0,1],'symmetric');
bH = imfilter(f,[-1,0,1]','symmetric');

V = nan(M,N);
V(cornermask) = max(abs(bV(cornermask)),abs(bH(cornermask)));
V(vmask) = abs(bV(vmask));
V(hmask) = abs(bH(hmask));
V(centermask) = 0;

Vdata = V(bmask);
F = scatteredInterpolant(R,C,Vdata);
[RR,CC] = find(true(size(f)));
BDmap = F(RR,CC);   % Block discontinuity map
BDmap = reshape(BDmap,size(f));
sigma_r = max(sigma_min,k0*BDmap);

end

function [ bmask,vmask,hmask,cornermask,centermask ] = edgeMask(M,N)
Br = floor(M/8);
Bc = floor(N/8);

vtile = false(8);
vtile(2:7,[1,8]) = true;

htile = false(8);
htile([1,8],2:7) = true;

crtile = false(8);
crtile(1,1) = true;
crtile(1,8) = true;
crtile(8,1) = true;
crtile(8,8) = true;

cntile = false(8);
cntile(4:5,4:5) = true;

btile = vtile | htile | crtile | cntile;

vmask = repmat(vtile,Br+1,Bc+1);
vmask = vmask(1:M,1:N);
hmask = repmat(htile,Br+1,Bc+1);
hmask = hmask(1:M,1:N);
cornermask = repmat(crtile,Br+1,Bc+1);
cornermask = cornermask(1:M,1:N);
centermask = repmat(cntile,Br+1,Bc+1);
centermask = centermask(1:M,1:N);
bmask = repmat(btile,Br+1,Bc+1);
bmask = bmask(1:M,1:N);

end



