function [ C ] = fitPolynomial( f,rho,N,Alpha,Beta,filtertype )
%FITPOLYNOMIAL
% Fit a polynomial on the local histogram at every pixel by moment-matching
% Input args:
%   f = m-by-n input image (double precision)
%   sigma_s = S.D. of Gaussian spatial kernel OR half-width of box kernel
%   N = Degree of polynomial
%   Alpha = m-by-n array containing pixelwise local minimum in window
%   Beta = m-by-n array containing pixelwise local maximum in window
%   filtertype = Type of spatial filter, 'box' or 'gaussian'
% Output args:
%   C = L-by-(N+1) matrix of polynomial coefficients, where L is the number
%       of pixels for which Alpha~=Beta

if(strcmp(filtertype,'gaussian'))
    spker = fspecial('gaussian',6*rho+1,rho);
else
    spker = fspecial('average',2*rho+1);
end

% Find pixels where Alpha=Beta or Alpha=0
mask = (Alpha~=Beta);
num_pixels = nnz(mask);
Alpha = Alpha(mask);  Beta = Beta(mask);
Alpha0_mask = (Alpha==0);
Alpha_non0 = Alpha(~Alpha0_mask);
Beta_non0 = Beta(~Alpha0_mask);

% Filter powers of f
fpow_filt = zeros(nnz(mask),1,N+1);
fpow = ones(size(f));
zero = 1;
fpow_filt(:,:,zero) = 1;
for k = 1:N
    fpow = fpow.*f;
    fbar = imfilter(fpow,spker,'symmetric');
    fpow_filt(:,:,zero+k) = fbar(mask);
end

% Compute moments of the shifted histograms (using numerically stable recursion)
zero = 1;
M = nan(num_pixels,N+1);
M(:,zero) = 1;  % 0th moment is always 1
multiplier = ones(nnz(~Alpha0_mask),1);
Beta_k = ones(nnz(Alpha0_mask),1);
for k = 1:N
    Beta_k = Beta_k.*Beta(Alpha0_mask);
    multiplier = multiplier.*(-Alpha_non0./(Beta_non0-Alpha_non0));
    prevTerm = multiplier;
    non0_mom = prevTerm;
    for r = 1:k
        temp1 = fpow_filt(:,:,zero+r);
        temp2 = fpow_filt(:,:,zero+r-1);
        nextTerm = ((r-k-1)/r) *...
                ( temp1(~Alpha0_mask)./...
                  (Alpha_non0.*temp2(~Alpha0_mask)) ) .*...
                prevTerm;
        non0_mom = non0_mom + nextTerm;
        prevTerm = nextTerm;
    end
    mom_k = zeros(num_pixels,1);
    mom_k(~Alpha0_mask) = non0_mom;
    temp = fpow_filt(:,:,zero+k);
    mom_k(Alpha0_mask) = temp(Alpha0_mask)./(Beta_k);
    M(:,zero+k) = mom_k;
end
M = M';

% Compute polynomial coefficients
Hinv = invhilb(N+1);
C = Hinv*M;
C = C';

end
