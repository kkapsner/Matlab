#include "mex.h"

/*
 * convexHull_cpp.cpp
 * only to be called from convexHull.m
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *image, *hullX, *hullY, *hullImage;
    int imageSize[2];
    int hullSize;
	
	if (nrhs != 3){
		mexErrMsgIdAndTxt( "MATLAB:convexHull_cpp:inputNotDouble",
				"Three inputs (image, hullX and hullY) expected.");
	}
	
	/* The input must be a double.*/
	if(!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2])){
		mexErrMsgIdAndTxt( "MATLAB:convexHull_cpp:inputNotDouble",
				"Input must be a double.");
	}

    imageSize[0] = (int) mxGetM(prhs[0]);
    imageSize[1] = (int) mxGetN(prhs[0]);
    image = mxGetPr(prhs[0]);
    
    hullSize = (int) mxGetM(prhs[1]) * mxGetN(prhs[1]);
    hullX = mxGetPr(prhs[1]);
    hullY = mxGetPr(prhs[2]);

    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(imageSize[0], imageSize[1], mxREAL);
    hullImage = mxGetPr(plhs[0]);
    
    for (int x = 0; x < imageSize[1]; x++){
        int x_ = x * imageSize[0];
        for (int y = 0; y < imageSize[0]; y++){
            hullImage[y + x_] = 1;
            if (!image[y + x_]){
                for (int i = 0; i < hullSize - 1; i++){
                    if (
                        (x - hullX[i]) * (hullY[i] - hullY[i + 1]) +
                        (y - hullY[i]) * (hullX[i + 1] - hullX[i]) < 0
                    ){
                        hullImage[y + x_] = 0;
                        break;
                    }
                }
            }
        }
    }
}