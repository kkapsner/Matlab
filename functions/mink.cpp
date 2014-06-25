#include "mex.h"
#include <algorithm>

/* create NaN */
unsigned long _nan[2]={0xffffffff, 0x7fffffff};
double NaN = *( double* )_nan;

/*
 * mink.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *list, *data;
    int listSize, dataSize;

    /* Check for proper number of arguments. */
    if(nrhs != 2) {
        mexErrMsgIdAndTxt( "MATLAB:mink:invalidNumInputs",
            "Two inputs required.");
    } else if(nlhs > 1) {
        mexErrMsgIdAndTxt( "MATLAB:mink:maxlhs",
            "Too many output arguments.");
    }

    /* The input must be a noncomplex double.*/
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
        !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
        mexErrMsgIdAndTxt( "MATLAB:mink:inputNotRealDouble",
            "Input must be a noncomplex double.");
    }

    dataSize = (int) mxGetM(prhs[0]) * (int) mxGetN(prhs[0]);
    data = mxGetPr(prhs[0]);

    listSize = (int) mxGetPr(prhs[1])[0];
    
    if (listSize > dataSize){
        mexErrMsgIdAndTxt( "MATLAB:mink:tooLessDataPoints",
            "Too less data points.");
        
    }

    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(listSize, 1, mxREAL);
    list = mxGetPr(plhs[0]);
	
	std::copy(data, data + listSize, list);
	std::make_heap(list, list + listSize);
	
	for (unsigned int i = listSize; i < dataSize; i += 1){
		if (data[i] < list[0]){
			std::pop_heap(list, list + listSize);
			list[listSize - 1] = data[i];
			std::push_heap(list, list + listSize);
		}
	}
	std::sort_heap(list, list + listSize);
}