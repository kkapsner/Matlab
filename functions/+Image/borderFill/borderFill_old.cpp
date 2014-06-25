#include "mex.h"
#define idx(dx, dy) (x + dx) * h + y + dy
#define check(dx, dy){\
    if ((image[idx(dx, dy)] == color) && !outImage[idx(dx, dy)]){\
        fill(image, h, w, y + dy, x + dx, color, outImage);\
    }\
}

/*
 * borderFill.cpp
 */

void fill(mxLogical *image, mwSize h, mwSize w, int y, int x, mxLogical color, mxLogical *outImage){
    outImage[idx(0, 0)] = 1;
    if (y > 0){
        if (x > 0){
//             check(-1, -1);
        }
        check(0, -1);
        if (x < w - 1){
//             check(1, -1);
        }
    }
    if (x > 0){
        check(-1, 0);
    }
    if (x < w - 1){
        check(1, 0);
    }
    if (y < h - 1){
        if (x > 0){
//             check(-1, 1);
        }
        check(0, 1);
        if (x < w - 1){
//             check(1, 1);
        }
    }
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    mxLogical *image, *outImage;
    mwSize w, h;
	
	if (nrhs != 1){
		mexErrMsgIdAndTxt( "MATLAB:borderFill:wrongInputCount",
				"One input (image) expected.");
	}
	
	/* The input must be a logical.*/
	if(!mxIsLogical(prhs[0])){
		mexErrMsgIdAndTxt( "MATLAB:borderFill:inputNotLogical",
				"Input must be a logical.");
	}

    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
    image = mxGetLogicals(prhs[0]);

    /* Create matrix for the return argument. */
    plhs[0] = mxCreateLogicalMatrix(h, w);
    outImage = mxGetLogicals(plhs[0]);
    
    /* first and last column */
    for (int y = 0; y < h; y++){
        if (!outImage[y]){
            fill(image, h, w, y, 0, image[y], outImage);
        }
        if (!outImage[h * (w - 1) + y]){
            fill(image, h, w, y, w - 1, image[h * (w - 1) + y], outImage);
        }
    }
    
    /* first and last row */
    for (int x = 1; x < w - 1; x++){
        if (!outImage[x * h]){
            fill(image, h, w, 0, x, image[x * h], outImage);
        }
        if (!outImage[x * h + h - 1]){
            fill(image, h, w, h - 1, x, image[x * h + h - 1], outImage);
        }
    }
}