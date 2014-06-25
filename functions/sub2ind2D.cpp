#include "mex.h"
/*
 * ind2sub2D.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *size, *ind, *xInd, *yInd;
	mwSize w, h;
	
	if (nrhs != 3){
		mexErrMsgIdAndTxt( "MATLAB:ind2sub2D:wrongInputCount",
				"Three inputs (size, indY, indX) expected.");
	}
	
	/* The input must be a logical.*/
	if(!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2])){
		mexErrMsgIdAndTxt( "MATLAB:ind2sub2D:inputNotDouble",
				"Input must be double.");
	}

    if (mxGetM(prhs[0]) * mxGetN(prhs[0]) != 2){
		mexErrMsgIdAndTxt( "MATLAB:ind2sub2D:wrongSize",
				"First input must have size 2.");
	};
    size = mxGetPr(prhs[0]);
    h = mxGetM(prhs[1]);
    w = mxGetN(prhs[1]);
    yInd = mxGetPr(prhs[1]);
    xInd = mxGetPr(prhs[2]);

    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(h, w, mxREAL);
    ind = mxGetPr(plhs[0]);
    
    for (int x = 0; x < w; x++){
		for (int y = 0; y < h; y++){
			int idx = x * h + y;
			ind[idx] = yInd[idx] - 1 + (xInd[idx] - 1) * size[0] + 1;
		}
	}
}