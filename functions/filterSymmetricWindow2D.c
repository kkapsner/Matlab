#include "mex.h"
#define min(a, b)(((a) < (b))? (a): (b))

/*
 * filterSymmetricWindow2D.c
 */

double getValue(const int x, const int y,
                const double window[], const int windowSize[],
                const double data[], const int dataSize[])
{
    int i, j;
    int baseIndex = x * dataSize[0] + y, windowIndex;
    int topStart = min(windowSize[0] - 1, y);
    int bottomStart = min(windowSize[0] - 1, dataSize[0] - 1 - y);
    int leftStart = min(windowSize[1] - 1, x);
    int rightStart = min(windowSize[1] - 1, dataSize[1] - 1 - x);
    double sum, value;
    
    // center
    sum = window[0];
    value = window[0] * data[baseIndex];
    
    // first column
    // top part
    for (i = topStart; i > 0; i--){
        sum += window[i];
        value += window[i] * data[baseIndex - i];
    }
    // bottom part
    for (i = bottomStart; i > 0; i--){
        sum += window[i];
        value += window[i] * data[baseIndex + i];
    }
    
    // first row
    // left part
    for (i = leftStart; i > 0; i--){
        windowIndex = i * windowSize[0];
        sum += window[windowIndex];
        value += window[windowIndex] * data[baseIndex - i * dataSize[0]];
    }
    // right part
    for (i = rightStart; i > 0; i--){
        windowIndex = i * windowSize[0];
        sum += window[windowIndex];
        value += window[windowIndex] * data[baseIndex + i * dataSize[0]];
    }
    
    // top 
    for (i = topStart; i > 0; i--){
        // left
        for (j = leftStart; j > 0; j--){
            windowIndex = i + j * windowSize[0];
            sum += window[windowIndex];
            value += window[windowIndex] *
                    data[baseIndex - i - j * dataSize[0]];
        }
        
        // right
        for (j = rightStart; j > 0; j--){
            windowIndex = i + j * windowSize[0];
            sum += window[windowIndex];
            value += window[windowIndex] *
                    data[baseIndex - i + j * dataSize[0]];
        }
    }
    
    // bottom
    for (i = bottomStart; i > 0; i--){
        // left
        for (j = leftStart; j > 0; j--){
            windowIndex = i + j * windowSize[0];
            sum += window[windowIndex];
            value += window[windowIndex] *
                    data[baseIndex + i - j * dataSize[0]];
        }
        
        //right
        for (j = rightStart; j > 0; j--){
            windowIndex = i + j * windowSize[0];
            sum += window[windowIndex];
            value += window[windowIndex] *
                    data[baseIndex + i + j * dataSize[0]];
        }
    }
    
    if (sum == 0){
        return 0;
    }
    else {
        return value / sum;
    }
}


void filterSymmetricWindow2D( double filtered[],
                            const double window[], const int windowSize[],
                            const double data[], const int dataSize[])
{
    /* Core loops to get the value of every output point*/
    int x, y;
    for (y = 0; y < dataSize[0]; y++){
        for (x = 0; x < dataSize[1]; x++){
            filtered[x * dataSize[0] + y] = getValue(x, y, window, windowSize, data, dataSize);
        }
    }
    
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *window, *data, *filtered;
  int windowSize[2], dataSize[2];
  
  /* Check for proper number of arguments. */
  if(nrhs != 2) {
    mexErrMsgIdAndTxt( "MATLAB:filterSymmetricWindow2D:invalidNumInputs",
            "Two inputs required.");
  } else if(nlhs > 1) {
    mexErrMsgIdAndTxt( "MATLAB:filterSymmetricWindow2D:maxlhs",
            "Too many output arguments.");
  }
  
  /* The input must be a noncomplex double.*/
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
    mexErrMsgIdAndTxt( "MATLAB:filterSymmetricWindow2D:inputNotRealDouble",
            "Input must be a noncomplex double.");
  }
  
  windowSize[0] = (int) mxGetM(prhs[0]);
  windowSize[1] = (int) mxGetN(prhs[0]);
  dataSize[0] = (int) mxGetM(prhs[1]);
  dataSize[1] = (int) mxGetN(prhs[1]);
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(dataSize[0], dataSize[1], mxREAL);
  
  /* Assign pointers to each input and output. */
  window = mxGetPr(prhs[0]);
  data = mxGetPr(prhs[1]);
  filtered = mxGetPr(plhs[0]);
  
  /* Call the filterSymmetricWindow2D subroutine. */
  filterSymmetricWindow2D(filtered,
          window, windowSize,
          data, dataSize);
}
