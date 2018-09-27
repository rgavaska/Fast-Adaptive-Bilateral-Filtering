
### Fast Adaptive Bilateral Filtering

This is a Matlab implementation of the algorithm in the following paper:

R. G. Gavaskar and K. N. Chaudhury, "Fast Adaptive Bilateral Filtering", IEEE Transactions on Image Processing, accepted.

DOI: 10.1109/TIP.2018.2871597

[[Early access version]](https://ieeexplore.ieee.org/document/8469064/)

Before running the code, compile the MEX file in the 'fastABF' directory as follows:
```
mex MinMaxFilter.cpp
```

The core source files implementing the algorithm are located in 'fastABF'.
To execute the algorithm, run the command
```
fastABF( f,rho,sigma,theta)
```
where
```
f         = input image (m-by-n),
rho     = width of the spatial Gaussian kernel,
sigma = width of the range Gaussian kernel, defined pixelwise (m-by-n),
theta   = centering of the range Gaussian kernel, defined pixelwise (m-by-n),
```

The main directory contains files to demonstrate application of the algorithm for image sharpening and noise removal, texture filtering, and JPEG deblocking.
Run the files 'demo_sharpening.m', 'demo_texture.m', and 'demo_deblocking.m' respectively.

The image 'fish.jpg' used for texture filtering has been downloaded from the [[project webpage]](http://www.cse.cuhk.edu.hk/~leojia/projects/texturesep/index.html) for the following paper:

L. Xu, Q. Yan, Y. Xia, and J. Jia, ''Structure extraction from texture via relative total variation,'' ACM Transactions on Graphics (TOG), 31(6), Article 139 (2012).

