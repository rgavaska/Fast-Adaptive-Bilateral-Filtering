/*
 * =====================================================================================
 *
 *       Filename:  MinMaxFilter.cpp
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  Thursday 05 October 2017 04:03:22  IST
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Ruturaj Gavaskar (), 
 *   Organization:  
 *
 * =====================================================================================
 */

#ifndef MINMAXFILTER_CPP
#define MINMAXFILTER_CPP

#include <iostream>
#include <cstring>
#include <vector>
#include <limits>

void applyPostReplicatePadding(double* in, int rows, int cols, int rowpad, int colpad, double* out)
{
    double *src, *dst;
    if(colpad==0)
    {
        std::memcpy(out,in,rows*cols*sizeof(double));
    }
    else
    {
        for(int i=0; i<rows; i++)
        {
            src = in + i*cols;              // ith row of input
            dst = out + i*(cols+colpad);    // ith row of output
            std::memcpy(dst,src,cols*sizeof(double)); // Copy row
            for(int k=cols; k<cols+colpad; k++)
            {
                dst[k] = dst[cols-1];       // Replicate last element
            }
        }
    }
    for(int i=rows; i<rows+rowpad; i++)
    {
        src = out + (rows-1)*(cols+colpad);
        dst = out + i*(cols+colpad);
        std::memcpy(dst,src,(cols+colpad)*sizeof(double)); // Replicate last row
    }
}


void minmaxFilter(double* f, int minput, int ninput, int w, double* fmin, double* fmax)
{
    int sym = (w-1)/2;
    int rowpad = (minput/w + (minput%w != 0))*w - minput;
    int columnpad = (ninput/w + (ninput%w != 0))*w - ninput;
    double* templateMax = new double[(minput+rowpad)*(ninput+columnpad)];
    double* templateMin = new double[(minput+rowpad)*(ninput+columnpad)];
    applyPostReplicatePadding(f,minput,ninput,rowpad,columnpad,templateMax);
    applyPostReplicatePadding(f,minput,ninput,rowpad,columnpad,templateMin);
    int m = minput+rowpad;
    int n = ninput+columnpad;
    std::vector<double> Lmin,Rmin,Lmax,Rmax;
    int k,p,q;
    double rmax,lmax,rmin,lmin;
    double *tminptr, *tmaxptr;

    /* Scan along rows */
    Lmax.resize(n); Lmin.resize(n);
    Rmax.resize(n); Rmin.resize(n);
    for(int ii=1; ii<=minput; ii++)
    {
        tmaxptr = templateMax+(ii-1)*n;
        tminptr = templateMin+(ii-1)*n;
        Lmax[0] = tmaxptr[0]; Lmin[0] = tminptr[0];
        Rmax[n-1] = tmaxptr[n-1]; Rmin[n-1] = tminptr[n-1];
        for(k=2; k<=n; k++)
        {
            if((k-1)%w==0)
            {
                Lmax[k-1] = tmaxptr[k-1];
                Rmax[n-k] = tmaxptr[n-k];
                Lmin[k-1] = tminptr[k-1];
                Rmin[n-k] = tminptr[n-k];
            }
            else
            {
                Lmax[k-1] = (Lmax[k-2]>tmaxptr[k-1]) ? Lmax[k-2] : tmaxptr[k-1];
                Rmax[n-k] = (Rmax[n-k+1]>tmaxptr[n-k]) ? Rmax[n-k+1] : tmaxptr[n-k];
                Lmin[k-1] = (Lmin[k-2]<tminptr[k-1]) ? Lmin[k-2] : tminptr[k-1];
                Rmin[n-k] = (Rmin[n-k+1]<tminptr[n-k]) ? Rmin[n-k+1] : tminptr[n-k];
            }
        }
        for(k=1; k<=n; k++)
        {
            p = k - sym;
            q = k + sym;
            rmax = (p<1) ? -1 : Rmax[p-1];
            rmin = (p<1) ? std::numeric_limits<double>::infinity() : Rmin[p-1];
            lmax = (q>n) ? -1 : Lmax[q-1];
            lmin = (q>n) ? std::numeric_limits<double>::infinity() : Lmin[q-1];
            tmaxptr[k-1] = (rmax>lmax) ? rmax : lmax;
            tminptr[k-1] = (rmin<lmin) ? rmin : lmin;
        }
    }

    /* Scan along columns */
    Lmax.resize(m); Lmin.resize(m);
    Rmax.resize(m); Rmin.resize(m);
    for(int jj=1; jj<=ninput; jj++)
    {
        tmaxptr = templateMax+jj-1;
        tminptr = templateMin+jj-1;
        Lmax[0] = tmaxptr[0]; Lmin[0] = tminptr[0];
        Rmax[m-1] = tmaxptr[(m-1)*n]; Rmin[m-1] = tminptr[(m-1)*n];
        for(k=2; k<=m; k++)
        {
            if((k-1)%w==0)
            {
                Lmax[k-1] = tmaxptr[(k-1)*n];
                Rmax[m-k] = tmaxptr[(m-k)*n];
                Lmin[k-1] = tminptr[(k-1)*n];
                Rmin[m-k] = tminptr[(m-k)*n];
            }
            else
            {
                Lmax[k-1] = (Lmax[k-2]>tmaxptr[(k-1)*n]) ? Lmax[k-2] : tmaxptr[(k-1)*n];
                Rmax[m-k] = (Rmax[m-k+1]>tmaxptr[(m-k)*n]) ? Rmax[m-k+1] : tmaxptr[(m-k)*n];
                Lmin[k-1] = (Lmin[k-2]<tminptr[(k-1)*n]) ? Lmin[k-2] : tminptr[(k-1)*n];
                Rmin[m-k] = (Rmin[m-k+1]<tminptr[(m-k)*n]) ? Rmin[m-k+1] : tminptr[(m-k)*n];
            }
        }
        for(k=1; k<=m; k++)
        {
            p = k - sym;
            q = k + sym;
            rmax = (p<1) ? -1 : Rmax[p-1];
            rmin = (p<1) ? std::numeric_limits<double>::infinity() : Rmin[p-1];
            lmax = (q>m) ? -1 : Lmax[q-1];
            lmin = (q>m) ? std::numeric_limits<double>::infinity() : Lmin[q-1];
            if(k<=minput)
            {
                fmax[(k-1)*ninput+jj-1] = (rmax>lmax) ? rmax : lmax;
                fmin[(k-1)*ninput+jj-1] = (rmin<lmin) ? rmin : lmin;
            }
        }
    }

    delete [] templateMax;
    delete [] templateMin;
}


void matTranspose(double* in, int rows, int cols, double* out)
{
    for(int i=0; i<rows; i++)
    {
        for(int j=0; j<cols; j++)
        {
            out[j*rows+i] = in[i*cols+j];
        }
    }
}


#ifdef MATLAB_MEX_FILE  /* Only used if compiling as a MATLAB MEX function */
#include "mex.h"
#define IMAGE_IN        prhs[0]
#define WINSIZE         prhs[1]
#define ALPHA           plhs[0]
#define BETA            plhs[1]

void mexFunction(int nlhs, mxArray **plhs, int nrhs, const mxArray **prhs)
{
    if(nrhs!=2 || nlhs!=2)
    {
        mexErrMsgTxt("Usage: [fmin,fmax] = mexMinMaxFilter(f,w)");
    }
    if(!mxIsNumeric(WINSIZE) || mxGetNumberOfElements(WINSIZE) != 1
       || mxGetScalar(WINSIZE) <= 0)
    {
        mexErrMsgTxt("w must be a positive odd integer");
    }

    int w = static_cast<int>(mxGetScalar(WINSIZE));
    if(w%2==0) { mexErrMsgTxt("w must be odd"); }

    const mwSize* size;
    size = mxGetDimensions(IMAGE_IN);
    int rows = static_cast<int>(size[0]);
    int columns = static_cast<int>(size[1]);

    double* f = mxGetPr(IMAGE_IN);
    ALPHA = mxCreateDoubleMatrix(rows, columns, mxREAL);
    BETA  = mxCreateDoubleMatrix(rows, columns, mxREAL);
    double* alpha = mxGetPr(ALPHA);
    double* beta  = mxGetPr(BETA);

    /* Matlab stores a matrix in column-major form. Convert it to
       row-major form first. */
    double* F = new double[rows*columns];
    matTranspose(f,columns,rows,F);

    double* alpha_temp = new double[rows*columns];
    double* beta_temp = new double[rows*columns];
    minmaxFilter(F,rows,columns,w,alpha_temp,beta_temp);
    matTranspose(alpha_temp,rows,columns,alpha);
    matTranspose(beta_temp,rows,columns,beta);

//    minmaxFilter(f,rows,columns,w,alpha,beta);
    delete [] F;
    delete [] alpha_temp;
    delete [] beta_temp;
}

#endif  /* MATLAB_MEX_FILE */

#endif  /* MINMAXFILTER_CPP */

