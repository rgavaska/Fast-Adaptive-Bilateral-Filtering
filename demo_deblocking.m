
clearvars; close all;
clc;

input_image = './house.jpg'; 
sigma_s = 3;
N = 5;      % Order of polynomial

f = imread(input_image);
f = double(f);
sigma_r = sigmaJPEG(f,15,1);
g_hat = fastABF(f,sigma_s,sigma_r,[],N);

figure, imshow(uint8(f)); title('Input');  drawnow; pause(0.01);
figure, imshow(uint8(g_hat)); title('Output');  drawnow; pause(0.01);
