
clearvars; close all;
clc;

input_image = './fish.jpg';
rho_smooth = 2;    % Spatial kernel parameter for smoothing step
rho_sharp = 4;     % Spatial kernel parameter for sharpening step

f = imread(input_image);
f = double(f);

addpath('./fastABF/');

% Set pixelwise sigma (range kernel parameters) for smoothing
M = mrtv(f,5);
sigma_smooth = linearMap(1-M,[0,1],[30,70]);
sigma_smooth = imdilate(sigma_smooth,strel('disk',2,4));  % Clean up the fine noise

% Apply fast algorithm to smooth textures
g = f;
tic;
for it = 1:2
    out = nan(size(f));
    for k = 1:size(f,3)
        out(:,:,k) = fastABF(g(:,:,k),rho_smooth,sigma_smooth,[],4);
    end
    g = out;
    sigma_smooth = sigma_smooth*0.8;
end

% Apply fast algorithm to sharpen edges
% Large variation in sigma is not required for this step
g_gray = double(rgb2gray(uint8(g)));
[zeta,sigma_sharp] = logClassifier(g_gray,rho_sharp,[30,31]);
for it = 1:2     % Run more iterations for greater sharpening
    for k = 1:size(f,3)
        g(:,:,k) = fastABF(g(:,:,k),rho_sharp,sigma_sharp,g(:,:,k)+zeta,5);
    end
end
toc;

figure, imshow(uint8(f)); title('Input');  drawnow; pause(0.01);
figure, imshow(uint8(g)); title('Output');  drawnow; pause(0.01);
