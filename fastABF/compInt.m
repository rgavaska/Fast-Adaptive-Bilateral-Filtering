function [ I ] = compInt( N,lambda,t0 )
%COMPINT
% Compute integrals using recursion
%   N = Degree of polynomial
%   lambda = Parameter of shifted Gaussian (see paper)
%   x0 = Center of shifted Gaussian (see paper)
%   I = Cell array (output) containing integrals

I = cell(1,N+1);
zero = 1;
rootL = sqrt(lambda);
Ulim = lambda.*(1-t0).*(1-t0);
expU = exp(-Ulim);

% Compute I_0 and I_1 directly
I{zero} = 0.5 * sqrt(pi./lambda) .* ...
    ( erf(rootL.*(1-t0)) - erf(-rootL.*t0) );
I{zero+1} = t0.*I{zero} - ...
    (expU - exp(-lambda.*t0.*t0))./(2*lambda);

for k = 2:N     % Use recurrence relation for k>1
    I{zero+k} = t0.*I{zero+k-1} + ...
        ((k-1)*I{zero+k-2} - expU)./(2*lambda);
end

end

