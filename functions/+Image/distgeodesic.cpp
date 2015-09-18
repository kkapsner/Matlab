#include "mex.h"

#include <iostream>
#define M_SQRT2		1.41421356237309504880
#define setDist(x, y, back, stepSize) \
{ \
	mwSize idx = (x) * h + (y); \
	if ( \
		y >= 0 && y < h && \
		x >= 0 && x < w && \
		image[idx] && \
		( \
			mxIsInf(dist[idx]) || \
			dist[idx] > dist[back] + stepSize \
		) \
	){ \
		dist[idx] = dist[back] + stepSize; \
		track[idx] = true; \
		any = true; \
	} \
}


/*
 * distgeodesic.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    mxLogical *image;
	mxLogical *path;
	bool *track;
	double *dist, *idx;
    mwSize w, h, size, sizeIdx, i, x, y;
	long conn;
	double inf = mxGetInf();
	double nan = mxGetNaN();
	
	if (nrhs < 2){
		mexErrMsgIdAndTxt( "Image:distgeodesic:wrongInputCount",
				"At least two input (image, startPoints) expected.");
	}
	if (nrhs > 3){
		mexErrMsgIdAndTxt( "Image:distgeodesic:wrongInputCount",
				"Too may input parameter.");
	}
	
	if (!mxIsDouble(prhs[1])){
		mexErrMsgIdAndTxt( "Image:distgeodesic:wrongInputType",
				"Index parameter has to be doubles.");
	}
	
	if (nrhs < 3 || mxGetM(prhs[2]) * mxGetN(prhs[2]) == 0){
		conn = 6;
	}
	else {
		if (mxIsDouble(prhs[2])){
			if (mxGetM(prhs[2]) * mxGetN(prhs[2]) == 1){
				conn = (long) mxGetPr(prhs[2])[0];
			}
			else {
				mexErrMsgIdAndTxt( "Image:distgeodesic:wrongInputType",
					"Connection parameter has to be a scalar.");
			}
		}
		else {
			mexErrMsgIdAndTxt( "Image:distgeodesic:wrongInputType",
				"Connection parameter has to be a double.");
		}
	}
	
    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
	size = h*w;
	/* The input must be a logical.*/
	if (!mxIsLogical(prhs[0])){
        image = mxGetLogicals(mxCreateLogicalMatrix(h, w));
        double *data = mxGetPr(prhs[0]);
        for (int i = 0; i < size; i += 1){
			image[i] = (mxLogical) data[i];
        }
	}
    else {
        image = mxGetLogicals(prhs[0]);
    }
	
	/* Create matrix for the return argument. */
	plhs[0] = mxCreateDoubleMatrix(h, w, mxREAL);
	dist = mxGetPr(plhs[0]);
	
	track = new bool[size];
	
	for (i = 0; i < size; i += 1){
		track[i] = false;
		dist[i] = image[i]? inf: nan;
	}
	
	idx = mxGetPr(prhs[1]);
	sizeIdx = mxGetM(prhs[1]) * mxGetN(prhs[1]);
	bool any = false;
	for (i = 0; i < sizeIdx; i += 1){
		mwSize startIdx = (long) idx[i];
		if (idx[i] != startIdx){
			mexErrMsgIdAndTxt( "Image:distgeodesic:idxNotIntegral",
					"Startindex has to be an integral number.");
		}
		if (startIdx <= 0 || startIdx > size){
			mexErrMsgIdAndTxt( "Image:distgeodesic:idxOutOfRange",
					"Startindex is out of range.");
		}
		track[startIdx - 1] = true;
		dist[startIdx - 1] = 0;
		any = true;
	}
	
	bool *trackCopy = new bool[size];
	while (any){
		any = false;
		for (i = 0; i < size; i += 1){
			trackCopy[i] = track[i];
		}
		
		for (i = 0; i < size; i += 1){ // cityblock
			if (trackCopy[i]){
				track[i] = false;
				y = i % h;
				x = (i - y) / h;
				setDist(x - 1, y, i, 1);
				setDist(x + 1, y, i, 1);
				setDist(x, y - 1, i, 1);
				setDist(x, y + 1, i, 1);
			}
		}
		if (conn == 6){ // chessboard
			for (i = 0; i < size; i += 1){
				if (trackCopy[i]){
					y = i % h;
					x = (i - y) / h;
					setDist(x - 1, y - 1, i, 1);
					setDist(x - 1, y + 1, i, 1);
					setDist(x + 1, y - 1, i, 1);
					setDist(x + 1, y + 1, i, 1);
				}
			}
		}
		if (conn == 8){ // quasi-euclidean
			for (i = 0; i < size; i += 1){
				if (trackCopy[i]){
					y = i % h;
					x = (i - y) / h;
					setDist(x - 1, y - 1, i, M_SQRT2);
					setDist(x - 1, y + 1, i, M_SQRT2);
					setDist(x + 1, y - 1, i, M_SQRT2);
					setDist(x + 1, y + 1, i, M_SQRT2);
				}
			}
		}
	}
	
	delete[] trackCopy;
	trackCopy = nullptr;
	
	
	/* free memory */
	delete[] track;
	track = nullptr;
}