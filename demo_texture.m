
clearvars; close all;
clc;

input_image = './fish.jpg';
rho = 2;    % Spatial kernel parameter

f = imread(input_image);
f = double(f);

addpath('./fastABF/');

% Set pixelwise sigma (range kernel parameters)
E = mrtv(f,5);
sigma_r = linearMap(1-E,[0,1],[30,70]);
sigma_r = imdilate(sigma_r,strel('disk',2,4));  % Clean up the fine noise

% Remove textures
g = f;
tic;
for it = 1:2
    out = nan(size(f));
    for k = 1:size(f,3)
        out(:,:,k) = fastABF(g(:,:,k),[],'gaussian',rho,sigma_r,4);
    end
    g = out;
    sigma_r = sigma_r*0.8;
end

% Sharpen edges
for it = 1:2     % Run more iterations for greater sharpening
g = sharpen_adaptive(g,4,30);
end
toc;

figure, imshow(uint8(f)); title('Input');  drawnow; pause(0.01);
figure, imshow(uint8(g)); title('Output');  drawnow; pause(0.01);
