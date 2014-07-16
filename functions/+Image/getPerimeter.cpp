#include "mex.h"
//#include "math.h"
#define idx(dx, dy) (x + dx) * h + y + dy
#define img(dx, dy) image[idx(dx, dy)]
#define DIAG p = p + d
#define ALONG p = p + 1

/*
 * getPerimeter.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    mxLogical *image;
    mwSize w, h;
	/* the perimeter */
    double p;
	
	/* size of a diagonal connection*/
    double d;
	
    p = 0;
    d = 0.70710678118654752440084436210485;//1/sqrt(2.0);
	
	if (nrhs != 1){
		mexErrMsgIdAndTxt( "MATLAB:getPerimeter:wrongInputCount",
				"One input (image) expected.");
	}

    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
    
    if (h < 2 || w < 2){
        
        plhs[0] = mxCreateDoubleScalar(0);
        return;
		mexWarnMsgIdAndTxt( "MATLAB:getPerimeter:inputNotMatrix",
				"Input must be a matrix not a vector or scalar."); 
    }
	
	/* The input must be a logical.*/
	if (!mxIsLogical(prhs[0])){
        image = mxGetLogicals(mxCreateLogicalMatrix(h, w));
        double *data = mxGetPr(prhs[0]);
        for (int x = 0; x < w; x += 1){
            for (int y = 0; y < h; y += 1){
                image[x * h + y] = (mxLogical) data[x * h + y];
            }
        }
//         mxArray *rhs[1];
//         mexCallMATLAB(1, rhs, 1, prhs, "logical");
//         image = mxGetLogicals(rhs[0]);
// 		mexErrMsgIdAndTxt( "MATLAB:getPerimeter:inputNotLogical",
// 				"Input must be a logical.");
	}
    else {
        image = mxGetLogicals(prhs[0]);
    }
    
    /* corners */
    if (image[0]){
        DIAG;
        DIAG;
        if (image[h]){
            ALONG;
        }
        else {
            DIAG;
            DIAG;
            if (image[1] & !image[h + 1]){
                ALONG;
            }
            else {
                DIAG;
            }
        }
        if (image[1]){
            ALONG;
        }
        else {
            DIAG;
            DIAG;
            if (image[h] & !image[h + 1]){
                ALONG;
            }
            else {
                DIAG;
            }
        }
    }
    if (image[h - 1]){
        DIAG;
        DIAG;
        if (image[h - 2]){
            ALONG;
        }
        else {
            DIAG;
            DIAG;
            if (image[h + h - 1] & !image[h + h - 2]){
                ALONG;
            }
            else {
                DIAG;
            }
        }
        
        if (image[h + h - 1]){
            ALONG;
        }
        else {
            DIAG;
            DIAG;
            if (image[h - 2] & !image[h + h - 2]){
                ALONG;
            }
            else {
                DIAG;
            }
        }
    }
    if (image[(w - 1) * h]){
        DIAG;
        DIAG;
        if (image[(w - 2) * h]){
            ALONG;
        }
        else {
            DIAG;
            DIAG;
            if (image[(w - 1) * h + 1] & !image[(w - 2) * h + 1]){
                ALONG;
            }
            else {
                DIAG;
            }
        }
        
        if (image[(w - 1) * h + 1]){
            ALONG;
        }
        else {
            DIAG;
            DIAG;
            if (image[(w - 2) * h] & !image[(w - 2) * h + 1]){
                ALONG;
            }
            else {
                DIAG;
            }
        }
    }
    if (image[w*h - 1]){
        DIAG;
        DIAG;
        if (image[w*h - 2]){
            ALONG;
        }
        else {
            DIAG;
            DIAG;
            if (image[w*h - 1 - h] & !image[(w - 2) * h + h - 2]){
                ALONG;
            }
            else {
                DIAG;
            }
        }
        
        if (image[w*h - 1 - h]){
            ALONG;
        }
        else {
            DIAG;
            DIAG;
            if (image[w*h - 2] & !image[(w - 2) * h + h - 2]){
                ALONG;
            }
            else {
                DIAG;
            }
        }
    }
    
    /* first row */
    for (int x = 1, y = 0; x < w - 1; x++){
        if (img(0, 0)){
//             if (!img(0, -1)){
                if (img(-1, 0)/* & !img(-1, -1)*/){
                    ALONG;
                }
                else {
                   DIAG;
                }

                if (img(1, 0)/* & !img(1, -1)*/){
                    ALONG;
                }
                else {
                    DIAG;
                }
//             }

            if (!img(0, 1)){
                if (img(-1, 0) & !img(-1, 1)){
                    ALONG;
                }
                else {
                    DIAG;
                }

                if (img(1, 0) & !img(1, 1)){
                    ALONG;
                }
                else {
                    DIAG;
                }
            }

            if (!img(-1, 0)){
                /*if (img(0, -1) & !img(-1, -1)){
                    ALONG;
                }
                else */{
                    DIAG;
                }

                if (img(0, 1) & !img(-1, 1)){
                    ALONG;
                }
                else {
                    DIAG;
                }
            }

            if (!img(1, 0)){
                /*if (img(0, -1) & !img(1, -1)){
                    ALONG;
                }
                else */{
                    DIAG;
                }

                if (img(0, 1) & !img(1, 1)){
                    ALONG;
                }
                else {
                    DIAG;
                }
            }
        }
    }
    
    /* last row */
    for (int x = 1, y = h - 1; x < w - 1; x++){
        if (img(0, 0)){
            if (!img(0, -1)){
                if (img(-1, 0) & !img(-1, -1)){
                    ALONG;
                }
                else {
                   DIAG;
                }

                if (img(1, 0) & !img(1, -1)){
                    ALONG;
                }
                else {
                    DIAG;
                }
            }

//             if (!img(0, 1)){
                if (img(-1, 0)/* & !img(-1, 1)*/){
                    ALONG;
                }
                else {
                    DIAG;
                }

                if (img(1, 0)/* & !img(1, 1)*/){
                    ALONG;
                }
                else {
                    DIAG;
                }
//             }

            if (!img(-1, 0)){
                if (img(0, -1) & !img(-1, -1)){
                    ALONG;
                }
                else {
                    DIAG;
                }

                /*if (img(0, 1) & !img(-1, 1)){
                    ALONG;
                }
                else */{
                    DIAG;
                }
            }

            if (!img(1, 0)){
                if (img(0, -1) & !img(1, -1)){
                    ALONG;
                }
                else {
                    DIAG;
                }

                /*if (img(0, 1) & !img(1, 1)){
                    ALONG;
                }
                else */{
                    DIAG;
                }
            }
        }
    }
    
    /* first column */
    for (int x = 0, y = 1; y < h - 1; y++){
        if (img(0, 0)){
            if (!img(0, -1)){
                /*if (img(-1, 0) & !img(-1, -1)){
                    ALONG;
                }
                else */{
                   DIAG;
                }

                if (img(1, 0) & !img(1, -1)){
                    ALONG;
                }
                else {
                    DIAG;
                }
            }

            if (!img(0, 1)){
                /*if (img(-1, 0) & !img(-1, 1)){
                    ALONG;
                }
                else */{
                    DIAG;
                }

                if (img(1, 0) & !img(1, 1)){
                    ALONG;
                }
                else {
                    DIAG;
                }
            }

//             if (!img(-1, 0)){
                if (img(0, -1)/* & !img(-1, -1)*/){
                    ALONG;
                }
                else {
                    DIAG;
                }

                if (img(0, 1)/* & !img(-1, 1)*/){
                    ALONG;
                }
                else {
                    DIAG;
                }
//             }

            if (!img(1, 0)){
                if (img(0, -1) & !img(1, -1)){
                    ALONG;
                }
                else {
                    DIAG;
                }

                if (img(0, 1) & !img(1, 1)){
                    ALONG;
                }
                else {
                    DIAG;
                }
            }
        }
    }
    
    /* lsat column */
    for (int x = w - 1, y = 1; y < h - 1; y++){
        if (img(0, 0)){
            if (!img(0, -1)){
                if (img(-1, 0) & !img(-1, -1)){
                    ALONG;
                }
                else {
                   DIAG;
                }

                /*if (img(1, 0) & !img(1, -1)){
                    ALONG;
                }
                else */{
                    DIAG;
                }
            }

            if (!img(0, 1)){
                if (img(-1, 0) & !img(-1, 1)){
                    ALONG;
                }
                else {
                    DIAG;
                }

                /*if (img(1, 0) & !img(1, 1)){
                    ALONG;
                }
                else */{
                    DIAG;
                }
            }

            if (!img(-1, 0)){
                if (img(0, -1) & !img(-1, -1)){
                    ALONG;
                }
                else {
                    DIAG;
                }

                if (img(0, 1) & !img(-1, 1)){
                    ALONG;
                }
                else {
                    DIAG;
                }
            }

//             if (!img(1, 0)){
                if (img(0, -1)/* & !img(1, -1)*/){
                    ALONG;
                }
                else {
                    DIAG;
                }

                if (img(0, 1)/* & !img(1, 1)*/){
                    ALONG;
                }
                else {
                    DIAG;
                }
//             }
        }
    }
    
    /* inner matrix */
    for (int x = 1; x < w - 1; x++){
        for (int y = 1; y < h - 1; y++){
            if (img(0, 0)){
                if (!img(0, -1)){
                    if (img(-1, 0) & !img(-1, -1)){
                        ALONG;
                    }
                    else {
                       DIAG;
                    }
                    
                    if (img(1, 0) & !img(1, -1)){
                        ALONG;
                    }
                    else {
                        DIAG;
                    }
                }
                
                if (!img(0, 1)){
                    if (img(-1, 0) & !img(-1, 1)){
                        ALONG;
                    }
                    else {
                        DIAG;
                    }
                    
                    if (img(1, 0) & !img(1, 1)){
                        ALONG;
                    }
                    else {
                        DIAG;
                    }
                }
                
                if (!img(-1, 0)){
                    if (img(0, -1) & !img(-1, -1)){
                        ALONG;
                    }
                    else {
                        DIAG;
                    }
                    
                    if (img(0, 1) & !img(-1, 1)){
                        ALONG;
                    }
                    else {
                        DIAG;
                    }
                }
                
                if (!img(1, 0)){
                    if (img(0, -1) & !img(1, -1)){
                        ALONG;
                    }
                    else {
                        DIAG;
                    }
                    
                    if (img(0, 1) & !img(1, 1)){
                        ALONG;
                    }
                    else {
                        DIAG;
                    }
                }
            }
        }
    }
    

    /* Create matrix for the return argument. */
	/* very edge is counted twice therefore p has to be divided by 2 */
    /* the correction factor taken from Z. Kulpa, Area and perimeter measurement
     * of blobs in discrete binary pictures. Comput. Graph. Image Process,
     * 6:434-451, 1977, doi:10.1016/s0146-664X(77)80021-x*/
//     plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
//     mxGetPr(plhs[0])[0] = p/2 * 0.94805944896851993568481554666752; //pi/8*(1+sqrt(2))
    plhs[0] = mxCreateDoubleScalar(p/2 * 0.94805944896851993568481554666752);
}