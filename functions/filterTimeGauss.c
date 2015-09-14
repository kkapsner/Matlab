#include "mex.h"
#define min(a, b)(((a) < (b))? (a): (b))
#define max(a, b)(((a) > (b))? (a): (b))

/*
 * filterSymmetricWindow.c
 */

double getValue(const int x,
                const double window[], const int windowSize,
                const double data[], const int dataSize)
{
    int i;
    double sum, value;
    sum = window[0];
    value = window[0] * data[x];
    for (i = 1; i < windowSize; i++){
        // not too far left
        if (x - i >= 0){
            sum += window[i];
            value += window[i] * data[x - i];
        }
        // not too far right
        if (x + i < dataSize){
            sum += window[i];
            value += window[i] * data[x + i];
        }
    }
    if (sum == 0){
        return 0;
    }
    else {
        return value / sum;
    }
}


void filterSymmetricWindow( double filtered[],
                            const double window[], const int windowSize,
                            const double data[], const int dataSize)
{
    int x;
    for (x = 0; x < dataSize; x++){
        filtered[x] = getValue(x, window, windowSize, data, dataSize);
    }
    
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *window, *data, *filtered;
  int windowSize[2], dataSize[2];
  
  /* Check for proper number of arguments. */
  if(nrhs != 2) {
    mexErrMsgIdAndTxt( "MATLAB:filterSymmetricWindow:invalidNumInputs",
            "Two inputs required.");
  } else if(nlhs > 1) {
    mexErrMsgIdAndTxt( "MATLAB:filterSymmetricWindow:maxlhs",
            "Too many output arguments.");
  }
  
  /* The input must be a noncomplex double.*/
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
    mexErrMsgIdAndTxt( "MATLAB:filterSymmetricWindow:inputNotRealDouble",
            "Input must be a noncomplex double.");
  }
  
  windowSize[0] = (int) mxGetM(prhs[0]);
  windowSize[1] = (int) mxGetN(prhs[0]);
  dataSize[0] = (int) mxGetM(prhs[1]);
  dataSize[1] = (int) mxGetN(prhs[1]);
  
  /* The input must be a noncomplex double.*/
  if( min(windowSize[0], windowSize[1]) != 1) {
    mexErrMsgIdAndTxt( "MATLAB:filterSymmetricWindow:window no vector",
            "Window input must be a vector.");
  }
  windowSize[0] = max(windowSize[0], windowSize[1]);
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(dataSize[0], dataSize[1], mxREAL);
  
  /* Assign pointers to each input and output. */
  window = mxGetPr(prhs[0]);
  data = mxGetPr(prhs[1]);
  filtered = mxGetPr(plhs[0]);
  
  /* Call the filterSymmetricWindow subroutine. */
  if (min(dataSize[0], dataSize[1]) != 1){
      int i;
      for (i = 0; i < dataSize[1]; i++){
          filterSymmetricWindow(&filtered[i * dataSize[0]],
              window, windowSize[0],
              &data[i * dataSize[0]], dataSize[0]);
      }
  }
  else {
      filterSymmetricWindow(filtered,
              window, windowSize[0],
              data, max(dataSize[0], dataSize[1]));
  }
}
