#include "mex.h"
/*
 * getSub.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *size, *ind, *xInd, *yInd, *data;
	double minX, maxX, sumX, minY, maxY, sumY;
	mwSize w, h, dataSize;
	
	if (nrhs != 2){
		mexErrMsgIdAndTxt( "MATLAB:getSub:wrongInputCount",
				"Two inputs (size, idx) expected.");
	}
	
	/* The input must be a logical.*/
	if(!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1])){
		mexErrMsgIdAndTxt( "MATLAB:getSub:inputNotDouble",
				"Input must be double.");
	}

    if (mxGetM(prhs[0]) * mxGetN(prhs[0]) != 2){
		mexErrMsgIdAndTxt( "MATLAB:getSub:wrongSize",
				"First input must have size 2.");
	};
    size = mxGetPr(prhs[0]);
    h = mxGetM(prhs[1]);
    w = mxGetN(prhs[1]);
    ind = mxGetPr(prhs[1]);

    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(h, w, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(h, w, mxREAL);
    yInd = mxGetPr(plhs[0]);
    xInd = mxGetPr(plhs[1]);
    
    for (int x = 0; x < w; x++){
		for (int y = 0; y < h; y++){
			int idx = x * h + y;
			yInd[idx] = (((int) ind[idx] - 1) % ((int) size[0])) + 1;
			xInd[idx] = ((ind[idx] - yInd[idx]) / size[0]) + 1;
		}
	}
	
	dataSize = w*h;
	minX = xInd[0];
	maxX = xInd[0];
	sumX = xInd[0];
	minY = yInd[0];
	maxY = yInd[0];
	sumY = yInd[0];
    for (int i = 1; i < dataSize; i++){
        if (xInd[i] < minX){
			minX = xInd[i];
		}
		else if (xInd[i] > maxX){
			maxX = xInd[i];
		}
		sumX += xInd[i];
		
        if (yInd[i] < minY){
			minY = yInd[i];
		}
		else if (yInd[i] > maxY){
			maxY = yInd[i];
		}
		sumY += yInd[i];
    }
    /* Create matrix for the return arguments. */
    plhs[2] = mxCreateDoubleMatrix(6, 1, mxREAL);
    data = mxGetPr(plhs[2]);
	data[0] = minY;
	data[1] = maxY;
	data[2] = (double) sumY / (double) dataSize;
	data[3] = minX;
	data[4] = maxX;
	data[5] = (double) sumX / (double) dataSize;
}