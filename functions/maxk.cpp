#include "mex.h"
#include <algorithm>
#include <functional>

/* create NaN */
unsigned long _nan[2]={0xffffffff, 0x7fffffff};
double NaN = *( double* )_nan;

/*
 * maxk.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *list, *data;
    int listSize, dataSize;

    /* Check for proper number of arguments. */
    if(nrhs != 2) {
        mexErrMsgIdAndTxt( "MATLAB:maxk:invalidNumInputs",
            "Two inputs required.");
    } else if(nlhs > 1) {
        mexErrMsgIdAndTxt( "MATLAB:maxk:maxlhs",
            "Too many output arguments.");
    }

    /* The input must be a noncomplex double.*/
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
        !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
        mexErrMsgIdAndTxt( "MATLAB:maxk:inputNotRealDouble",
            "Input must be a noncomplex double.");
    }

    dataSize = (int) mxGetM(prhs[0]) * (int) mxGetN(prhs[0]);
    data = mxGetPr(prhs[0]);

    listSize = (int) mxGetPr(prhs[1])[0];
    
    if (listSize > dataSize){
        mexErrMsgIdAndTxt( "MATLAB:maxk:tooLessDataPoints",
            "Too less data points.");
        
    }

    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(listSize, 1, mxREAL);
    list = mxGetPr(plhs[0]);
	
	auto comp = std::greater<double>();
	
	std::copy(data, data + listSize, list);
	std::make_heap(list, list + listSize, comp);
	
	for (unsigned int i = listSize; i < dataSize; i += 1){
		if (data[i] > list[0]){
			std::pop_heap(list, list + listSize, comp);
			list[listSize - 1] = data[i];
			std::push_heap(list, list + listSize, comp);
		}
	}
	std::sort_heap(list, list + listSize, comp);
}