#include "mex.h"

#include <iostream>
//#include "math.h"
#define setBacktrack(x, y, back) \
{ \
	mwSize idx = (x) * h + (y); \
	if (y >= 0 && y < h && x >= 0 && x < w && image[idx] && backtracks[idx] == -1){ \
		backtracks[idx] = back; \
		pathSteps[idx] = pathSteps[back] + 1; \
		track[idx] = true; \
		any = true; \
	} \
}


/*
 * getShortestPath.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    mxLogical *image;
	mxLogical *path;
	bool *track;
	double *pathIdx;
	long *pathSteps;
	long *backtracks;
    mwSize w, h, size, idx1, idx2, i, x, y;
	long conn;
	
	if (nrhs < 3){
		mexErrMsgIdAndTxt( "Image:getShortestPath:wrongInputCount",
				"At least three input (image, idx1, idx2) expected.");
	}
	if (nrhs > 4){
		mexErrMsgIdAndTxt( "Image:getShortestPath:wrongInputCount",
				"Too may input parameter.");
	}
	
	if (!mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2])){
		mexErrMsgIdAndTxt( "Image:getShortestPath:wrongInputType",
				"Index parameters has to be doubles.");
	}
	
	if (nrhs < 4 || mxGetM(prhs[3]) * mxGetN(prhs[3]) == 0){
		conn = 8;
	}
	else {
		if (mxIsDouble(prhs[3])){
			conn = (long) mxGetPr(prhs[3])[0];
		}
		else {
			mexErrMsgIdAndTxt( "Image:getShortestPath:wrongInputType",
				"Connection parameter has to be a double.");
		}
	}
	
    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
	size = h*w;
	
	idx1 = mxGetPr(prhs[1])[0] - 1;
	if (idx1 < 0 || idx1 >= size){
		mexErrMsgIdAndTxt( "Image:getShortestPath:idx1OutOfRange",
				"Index 1 is out of range.");
	}
	
	idx2 = mxGetPr(prhs[2])[0] - 1;
	if (idx2 < 0 || idx2 >= size){
		mexErrMsgIdAndTxt( "Image:getShortestPath:idx2OutOfRange",
				"Index 2 is out of range.");
	}
	
	
	
	track = new bool[size];
	pathSteps = new long[size];
	backtracks = new long[size];
	for (i = 0; i < size; i += 1){
		track[i] = false;
		pathSteps[i] = 0;
		backtracks[i] = -1;
	}
	
	track[idx1] = true;
	
	
	
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
	
	bool any = true;
	while (!track[idx2] && any){
		any = false;
		bool *trackCopy = new bool[size];
		for (i = 0; i < size; i += 1){
			trackCopy[i] = track[i];
		}
		
		for (i = 0; i < size; i += 1){
			if (trackCopy[i]){
				track[i] = false;
				y = i % h;
				x = (i - y) / h;
				setBacktrack(x - 1, y, i);
				setBacktrack(x + 1, y, i);
				setBacktrack(x, y - 1, i);
				setBacktrack(x, y + 1, i);
			}
		}
		if (conn == 8){
			for (i = 0; i < size; i += 1){
				if (trackCopy[i]){
					y = i % h;
					x = (i - y) / h;
					setBacktrack(x - 1, y - 1, i);
					setBacktrack(x - 1, y + 1, i);
					setBacktrack(x + 1, y - 1, i);
					setBacktrack(x + 1, y + 1, i);
				}
			}
		}
		delete[] trackCopy;
		trackCopy = nullptr;
	}
	
	if (!track[idx2]){
		mexErrMsgIdAndTxt("Image:getShortestPath:notConnected",
			"Points are not connected.");
	}
	
	
	/* Create matrix for the return argument. */
	plhs[0] = mxCreateLogicalMatrix(h, w);
	path = mxGetLogicals(plhs[0]);
	
	if (nlhs > 1){
		plhs[1] = mxCreateDoubleMatrix(pathSteps[idx2], 1, mxREAL);
		pathIdx = mxGetPr(plhs[1]);
	}
	else {
		pathIdx = new double(pathSteps[idx2]);
	}
	
	mwSize idx = idx2;
	i = pathSteps[idx2] - 1;
	while (idx != idx1){
		pathIdx[i] = idx + 1;
		i = i - 1;
		path[idx] = true;
		idx = backtracks[idx];
	}
	pathIdx[0] = idx + 1;
	path[idx] = true;
	
	/* free memory */
	delete[] track;
	track = nullptr;
	delete[] pathSteps;
	pathSteps = nullptr;
	delete[] backtracks;
	backtracks = nullptr;
	if (nlhs > 2){
		delete[] pathIdx;
		pathIdx = nullptr;
	}
}