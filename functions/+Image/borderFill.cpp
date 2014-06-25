#include "mex.h"
#include "borderFill/List.cpp"
#define idx(dx, dy) (x + dx) * h + y + dy
#define check(dx, dy){\
    idx = idx(dx, dy);\
    if ((image[idx] == image[idx0]) && !outImage[idx]){\
        outImage[idx] = 1;\
        pixelList.push(x + dx, y + dy);\
    }\
}

/*
 * borderFill.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    mxLogical *image, *outImage;
    mwSize w, h;
    borderFill::List pixelList;
	
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
        outImage[y] = 1;
        pixelList.push(0, y);
        outImage[h * (w - 1) + y] = 1;
        pixelList.push(w - 1, y);
    }
    
    /* first and last row */
    for (int x = 1; x < w - 1; x++){
        outImage[x * h] = 1;
        pixelList.push(x, 0);
        outImage[x * h + h - 1] = 1;
        pixelList.push(x, h - 1);
    }
    
    while (pixelList.head){
        int x = pixelList.head->x;
        int y = pixelList.head->y;
        int idx0 = idx(0, 0);
        int idx;
        pixelList.shift();
        
        if (y > 0){
            if (x > 0){
                check(-1, -1);
            }
            check(0, -1);
            if (x < w - 1){
                check(1, -1);
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
                check(-1, 1);
            }
            check(0, 1);
            if (x < w - 1){
                check(1, 1);
            }
        }
    }
}