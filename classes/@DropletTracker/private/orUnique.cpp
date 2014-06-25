#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] ){
    double *data, *indices;
    int dataSize[2];

    /* Check for proper number of arguments. */
    if(nrhs != 1) {
        mexErrMsgIdAndTxt( "MATLAB:DropletTracker:orUnique:invalidNumInputs",
                "One input argument required.");
    } else if(nlhs != 1) {
        mexErrMsgIdAndTxt( "MATLAB:DropletTracker:orUnique:maxlhs",
                "Only one and exactly one output argument supported.");
    }
  
    /* The input must be a noncomplex double.*/
    if(!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt( "MATLAB:DropletTracker:orUnique:inputNotRealDouble",
                "Input must be a noncomplex double.");
    }
  
    dataSize[0] = (int) mxGetM(prhs[0]);
    dataSize[1] = (int) mxGetN(prhs[0]);
    
    if (dataSize[1] == 0){
        dataSize[0] = 0;
    }
  
    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(dataSize[0], 1, mxREAL);

    /* Assign pointers to each input and output. */
    data = mxGetPr(prhs[0]);
    indices = mxGetPr(plhs[0]);
  
    for (int y = 0; y < dataSize[0]; y++){
        double index = 0;
        for (int y_ = 0; y_ < y; y_++){
            if (indices[y_]){
                continue;
            }
            for (int i = 0; i < dataSize[1]; i++){
                if (data[i * dataSize[0] + y] == data[i * dataSize[0] + y_]){
                    index = y_ + 1;
                    y_ = y;
                    break;
                }
            }
        }
        indices[y] = index;
    }
}