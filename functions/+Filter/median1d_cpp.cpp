#include "mex.h"
#include "../../../c++/medianFilter/List.cpp" //change this to the correct path!

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *window, *data, *filtered;
  int windowSize[2], dataSize[2];
  
  /* Check for proper number of arguments. */
  if(nrhs != 2) {
    mexErrMsgIdAndTxt( "MATLAB:Filter:median1d:invalidNumInputs",
            "Two input arguments required.");
  } else if(nlhs > 1) {
    mexErrMsgIdAndTxt( "MATLAB:Filter:median1d:maxlhs",
            "Too many output arguments.");
  }
  
  /* The input must be a noncomplex double.*/
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
    mexErrMsgIdAndTxt( "MATLAB:Filter:median1d:inputNotRealDouble",
            "Input must be a noncomplex double.");
  }
  
  dataSize[0] = (int) mxGetM(prhs[0]);
  dataSize[1] = (int) mxGetN(prhs[0]);
  windowSize[0] = (int) mxGetM(prhs[1]);
  windowSize[1] = (int) mxGetN(prhs[1]);
  
  if( windowSize[0] != 1 ||
          windowSize[1] != 1 ) {
    mexErrMsgIdAndTxt( "MATLAB:Filter:median1d:windowSizeNoScalar",
            "Window input must be a scalar.");
  }
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(dataSize[0], dataSize[1], mxREAL);
  mxSetDimensions(plhs[0], mxGetDimensions(prhs[0]), mxGetNumberOfDimensions(prhs[0]));
  
  /* Assign pointers to each input and output. */
  data = mxGetPr(prhs[0]);
  window = mxGetPr(prhs[1]);
  filtered = mxGetPr(plhs[0]);
  
  long windowS = (long) *window;
  if (windowS <= 0){
      windowS = 1;
  }
  
  /* Call the MedianFilter::filter subroutine. */
  if (dataSize[0] != 1 && dataSize[1] != 1){
      int i;
      for (i = 0; i < dataSize[1]; i++){
          MedianFilter::filter(
              &data[i * dataSize[0]],
              &filtered[i * dataSize[0]],
              dataSize[0],
              windowS
          );
      }
  }
  else {
      int size = dataSize[0] > dataSize[1]? dataSize[0]: dataSize[1];
      MedianFilter::filter(
              data, filtered, size,
              windowS
      );
  }
}