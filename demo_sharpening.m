
clearvars; close all;
clc;

input_image = './peppers_degraded.tif';
rho = 5;    % Standard deviation of Gaussian spatial kernel
N = 5;      % Order of polynomial

f = imread(input_image);
f = double(f);
figure; imshow(uint8(f)); title('Input image'); drawnow; pause(0.1);

% Set offset (zeta) and sigma values
[zeta,sigma_r] = logClassifier(f,rho,[23,33]);  % Adjust interval till output is satisfactory

%% Apply proposed fast algorithm & brute-force filter to compute sharpened image
% Proposed fast algorithm
addpath('./fastABF/');
fprintf('Running fast algorithm...\n');
tic;
g_hat = fastABF(f,rho,sigma_r,f+zeta,N);
g_hat(g_hat>255) = 255; g_hat(g_hat<0) = 0;
t1 = toc;
fprintf('Done. Runtime = %f sec\n\n', t1);

% Brute-force filter
fprintf('Running brute-force filter...\n');
tic;
g = abf_bruteforce(f,rho,sigma_r,f+zeta);
g(g>255) = 255; g(g<0) = 0;
t2 = toc;
fprintf('Done. Runtime = %f sec\n\n', t2);

fprintf('PSNR (bruteforce vs. fast) = %f dB\n', psnr(g_hat,g,255));

figure, imshow(uint8(g)); title('Output using brute-force filter'); drawnow; pause(0.1);
figure, imshow(uint8(g_hat)); title('Output using fast algorithm');  drawnow; pause(0.1);
