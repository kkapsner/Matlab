#include "mex.h"
#define isChange(l, m, r) (l ^ r) | (m & !l)

/*
 * bridge.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    mxLogical *image, *outImage;
    mwSize width, height;
	
	if (nrhs != 1){
		mexErrMsgIdAndTxt( "MATLAB:bridge:wrongInputCount",
				"One input (image) expected.");
	}
	
	/* The input must be a logical.*/
	if(!mxIsLogical(prhs[0])){
		mexErrMsgIdAndTxt( "MATLAB:bridge:inputNotLogical",
				"Input must be a logical.");
	}

    height = mxGetM(prhs[0]);
    width = mxGetN(prhs[0]);
    image = mxGetLogicals(prhs[0]);

    /* Create matrix for the return argument. */
    plhs[0] = mxDuplicateArray(prhs[0]);
    outImage = mxGetLogicals(plhs[0]);
    
    for (int x = 2; x < width - 2; x++){
        int x_ = x * height;
        for (int y = 2; y < height - 2; y++){
            int idx = x_ + y;
            if (!outImage[idx]){
                mxLogical a, a1, b, c, c1, d, e, e1, f, g, g1, h;
                /*
                 * the neighbourhood of the current pixel (indicated by an 
                 * X) look as follows:
				 *      a1
                 *    h a b
                 * g1 g X c c1
                 *    f e d
				 *      e1
                 * a, c, e and g are a combined with a1, c1, e1 and g1 in a
				 * second check round. This makes the algorithm a TWO pixel
				 * bridge algorithm.
                 */
                a  = image[idx - 1];
				a1 = a|image[idx - 2];
				
                b  = image[idx - 1 + height];
				
                c  = image[idx + height];
                c1 = c|image[idx + 2*height];
				
                d  = image[idx + 1 + height];
				
                e  = image[idx + 1];
                e1 = e|image[idx + 2];
				
                f  = image[idx + 1 - height];
				
                g  = image[idx - height];
                g1 = g|image[idx - 2*height];
				
                h  = image[idx - 1 - height];
                
                /*
                 * The bridge has to be build if there is a color change on
                 * two opposit corner of the 3x3 matrix shown above.
                 * 
                 * A color change is detected as the following patterns
                 * (the X indicates the center pixel a hyphen ("-")
                 * indicates either "0" or "1":
                 *  0 -  1 -  0 1
                 *  X 1  X 0  X 0
                 * 
                 * Therefore the "not color change" patterns are:
                 *  0 0  1 1  1 0
                 *  X 0  X 1  X 1
                 */
                outImage[idx] = (mxLogical)
                    (
						(
							(
								(isChange(a, b, c)) &
								(isChange(e, f, g))
							) |
							(
								(isChange(c, d, e)) &
								(isChange(g, h, a))
							)
						) &
						!(
							(a & !f & (a == c) & (e == g) & (a != g)) |
							(e & !b & (a == c) & (e == g) & (a != g)) |
							(c & !h & (c == e) & (g == a) & (a != c)) |
							(g & !d & (c == e) & (g == a) & (a != c))
						)
						
					) |
                    (
						(a || b || c || d || e || f || g || h) &
						(
							(
								(isChange(a1, b, c1)) &
								(isChange(e1, f, g1))
							) |
							(
								(isChange(c1, d, e1)) &
								(isChange(g1, h, a1))
							)
						) &
						!(
							(a1 & !f & (a1 == c1) & (e1 == g1) & (a1 != g1)) |
							(e1 & !b & (a1 == c1) & (e1 == g1) & (a1 != g1)) |
							(c1 & !h & (c1 == e1) & (g1 == a1) & (a1 != c1)) |
							(g1 & !d & (c1 == e1) & (g1 == a1) & (a1 != c1))
						)
						
					);
				if (outImage[idx]){
					if (a1){
						outImage[idx - 1] = 1;
					}
					if (c1){
						outImage[idx + height] = 1;
					}
					if (e1){
						outImage[idx + 1] = 1;
					}
					if (g1){
						outImage[idx - height] = 1;
					}
				}
            }
        }
    }
}