
### Fast Adaptive Bilateral Filtering

This is a Matlab implementation of the following paper:
R. G. Gavaskar and K. N. Chaudhury, "Fast Adaptive Bilateral Filtering", to be published in IEEE Transactions on Image Processing.
[[Early access version]](https://ieeexplore.ieee.org/document/8469064/)

Before running the code, compile the MEX file in the 'fastABF' directory as follows:
```
mex MinMaxFilter.cpp
```

The core source files implementing the algorithm are located in 'fastABF'.

The main directory contains files to demonstrate application of the algorithm for texture filtering. Run the file 'demo_texture.m'.

DOI: 10.1109/TIP.2018.2871597

