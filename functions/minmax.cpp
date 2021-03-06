#include "mex.h"

/* create NaN */
unsigned long _nan[2]={0xffffffff, 0x7fffffff};
double NaN = *( double* )_nan;

/*
 * minmax.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *data;
    int dataSize;
	double min, max;

    /* Check for proper number of arguments. */
    if(nrhs != 1) {
        mexErrMsgIdAndTxt( "MATLAB:minmax:invalidNumInputs",
            "One input required.");
    } else if(nlhs != 2) {
        mexErrMsgIdAndTxt( "MATLAB:minmax:invalidNumOutputs",
            "Two output arguments required.");
    }

    /* The input must be a noncomplex double.*/
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt( "MATLAB:minmax:inputNotRealDouble",
            "Input must be a noncomplex double.");
    }

    dataSize = (int) mxGetM(prhs[0]) * (int) mxGetN(prhs[0]);
    if (dataSize == 0){
		mexErrMsgIdAndTxt( "MATLAB:minmax:nonEmptyInput",
            "Input must not be empty.");
	}
	
    data = mxGetPr(prhs[0]);
	
	min = data[0];
	max = data[0];
    for (int i = 1; i < dataSize; i++){
        if (data[i] < min){
			min = data[i];
		}
		else if (data[i] > max){
			max = data[i];
		}
			
    }
    /* Create matrix for the return arguments. */
    plhs[0] = mxCreateDoubleScalar(min);
    plhs[1] = mxCreateDoubleScalar(max);
}