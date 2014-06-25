#include "mex.h"
#include <algorithm>
#include <math.h>

/*
 * wideBridge.cpp
 */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	unsigned int frameSize;
    mxLogical *image, *outImage;
    mwSize w, h;
	
	if (nrhs == 0){
		mexErrMsgIdAndTxt( "MATLAB:wideBridge:wrongInputCount",
				"At least one input (image) expected.");
	}
	if (nrhs == 1 || mxGetM(prhs[1]) * mxGetN(prhs[1]) == 0){
		frameSize = 2;
	}
	else {
		frameSize = (unsigned int) mxGetScalar(prhs[1]);
	}
	
	if (nrhs > 2){
		mexErrMsgIdAndTxt( "MATLAB:wideBridge:wrongInputCount",
				"Too many input parameter.");
	}
	
	/* The input must be a logical.*/
	if(!mxIsLogical(prhs[0])){
		mexErrMsgIdAndTxt( "MATLAB:wideBridge:inputNotLogical",
				"Input must be a logical.");
	}

    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
    image = mxGetLogicals(prhs[0]);

    /* Create matrix for the return argument. */
    plhs[0] = mxDuplicateArray(prhs[0]);
    outImage = mxGetLogicals(plhs[0]);
	
	for (unsigned int x = 0; x < w; x += 1){
        unsigned int x_ = x * h;
		for (unsigned int y = 0; y < h; y += 1){
            unsigned int idx = x_ + y;
			
			if (!outImage[idx]){
				// make frame smaller to fit into the image completely
				unsigned int maximalFrameSize = std::min(
					frameSize, 
					std::min(
						x,
						std::min(
							y,
							std::min(
								w - x - 1,
								h - y - 1
							)
						)
					)
				);
				
				// check all frames
				for (
					unsigned int currentFrameSize = 1;
					!outImage[idx] && currentFrameSize <= maximalFrameSize;
					currentFrameSize += 1
				){
					// check all four corners
					for (int xSign = -1; !outImage[idx] && xSign < 2; corner += 2){
						for (int ySign = -1; !outImage[idx] && ySign < 2; ySign += 2){
							unsigned int referenceIdx =
								(x + xSign * currentFrameSize) * h +
								(y + ySign * currentFrameSize);
							if (image[referenceIdx]){
								for (
									unsigned int otherSideX = 0;
									!outImage[idx] && otherSideX <= currentFrameSize;
									otherSideX += 1
								){
									double slope = 1.0 - 0.5 / ((double) frameSize);
									unsigned int otherSideYStart = ceil(((double) otherSideX) * slope - 0.5);
									unsigned int otherSideYEnd = std::min(
										currentFrameSize,
										floor(((double) otherSideX + 0.5) / slope)
									);
									for (
										unsigned int otherSideY = otherSideYStart;
										!outImage[idx] && otherSideY <= otherSideYEnd;
										otherSideY += 1
									){
										unsigned int otherSideIdx =
											(x + -1 * xSign * otherSideX) * h +
											(y + -1 * ySign * otherSideY);
										if (image[otherSideIdx]){
											outImage[idx] = 1;
										}
									}
								}
							}
						}
					}
					
					// check all left/right side points
					for (int xSign = -1; !outImage[idx] && xSign < 2; corner += 2){
						unsigned int referenceIdx =
							(x + xSign * currentFrameSize) * h +
							(y);
						if (image[referenceIdx]){
							for (
								unsigned int otherSideX = 1;
								!outImage[idx] && otherSideX <= currentFrameSize;
								otherSideX += 1
							){
								double slope = 0.5 / ((double) frameSize);
								signed int otherSideYEnd = floor(((double) otherSideX) * slope + 0.5);
								for (
									signed int otherSideY = -otherSideYEnd;
									!outImage[idx] && otherSideY <= otherSideYEnd;
									otherSideY += 1
								){
									unsigned int otherSideIdx =
										(x + -1 * xSign * otherSideX) * h +
										(y + otherSideY);
									if (image[otherSideIdx]){
										outImage[idx] = 1;
									}
								}
							}
						}
					}
					
					// check all top/left side points
					for (int ySign = -1; !outImage[idx] && ySign < 2; corner += 2){
						unsigned int referenceIdx =
							(x) * h +
							(y + ySign * currentFrameSize);
						if (image[referenceIdx]){
							for (
								unsigned int otherSideY = 1;
								!outImage[idx] && otherSideY <= currentFrameSize;
								otherSideY += 1
							){
								double slope = 0.5 / ((double) frameSize);
								signed int otherSideXEnd = floor(((double) otherSideY) * slope + 0.5);
								for (
									signed int otherSideX = -otherSideXEnd;
									!outImage[idx] && otherSideX <= otherSideXEnd;
									otherSideX += 1
								){
									unsigned int otherSideIdx =
										(x + otherSideX) * h +
										(y + -1 * ySign * otherSideY);
									if (image[otherSideIdx]){
										outImage[idx] = 1;
									}
								}
							}
						}
					}
					
					// check rest
					// four corners
					for (int xSign = -1; !outImage[idx] && xSign < 2; corner += 2){
						for (int ySign = -1; !outImage[idx] && ySign < 2; ySign += 2){
							
							// go horizontal
							for (unsigned int deltaX = 1; !outImage[idx] && deltaX < frameSize; deltaX += 1){
								unsigned int referenceIdx =
									(x + xSign * deltaX) * h +
									(y + ySign * currentFrameSize);
								if (image[referenceIdx]){
									double slope = 
								}
							}
							
							// go vertical
							for (unsigned int deltaY = 1; !outImage[idx] && deltaY < frameSize; deltaY += 1){
								unsigned int referenceIdx =
									(x + xSign * currentFrameSize) * h +
									(y + ySign * deltaY);
								if (image[referenceIdx]){
								}
							}
							
							unsigned int referenceIdx =
								(x + xSign * currentFrameSize) * h +
								(y + ySign * currentFrameSize);
							if (image[referenceIdx]){
								for (
									unsigned int otherSideX = 0;
									!outImage[idx] && otherSideX <= currentFrameSize;
									otherSideX += 1
								){
									double slope = 1.0 - 0.5 / ((double) frameSize);
									unsigned int otherSideYStart = ceil(((double) otherSideX) * slope - 0.5);
									unsigned int otherSideYEnd = std::min(
										currentFrameSize,
										floor(((double) otherSideX + 0.5) / slope)
									);
									for (
										unsigned int otherSideY = otherSideYStart;
										!outImage[idx] && otherSideY <= otherSideYEnd;
										otherSideY += 1
									){
										unsigned int otherSideIdx =
											(x + -1 * xSign * otherSideX) * h +
											(y + -1 * ySign * otherSideY);
										if (image[otherSideIdx]){
											outImage[idx] = 1;
										}
									}
								}
							}
						}
					}
					
				}
				
				
			}
		}
	}
    
    for (int x = 2; x < w - 2; x++){
        int x_ = x * h;
        for (int y = 2; y < h - 2; y++){
            if (!image[idx]){// && !outImage[idx]){
                mxLogical a, b, c, d, e, f, g, h_;
                /*
                 * the neighbourhood of the current pixel (indicated by an 
                 * X) look as follows:
                 *  h_ a b
                 *   g X c
                 *   f e d
                 * a, c, e and g are a combination of the indicated 
                 * position and the pixel one step further away of X. This
                 * makes the algorithm a TWO pixel wideBridge algorithm.
                 */
                h_ = image[idx - 1 - h];
                a = image[idx - 1] | image[idx - 2];
                b = image[idx - 1 + h];
                g = image[idx - 2*h] | image[idx - h];
                c = image[idx + h] | image[idx + 2*h];
                f = image[idx + 1 - h];
                e = image[idx + 1] | image[idx + 2];
                d = image[idx + 1 + h];
                
                /*
                 * The wideBridge has to be build if there is a color change on
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
                    ((
					    (isChange(a, b, c)) &
                        (isChange(e, f, g))
					) |
                    (
					    (isChange(c, d, e)) &
                        (isChange(g, h_, a))
					)) &
					!(
						(a & !f & (a == c) & (e == g) & (a != g)) |
						(e & !b & (a == c) & (e == g) & (a != g)) |
						(c & !h_& (c == e) & (g == a) & (a != c)) |
						(g & !d & (c == e) & (g == a) & (a != c))
					);
				if (outImage[idx]){
					if (a){
						outImage[idx - 1] = 1;
					}
					if (c){
						outImage[idx + h] = 1;
					}
					if (e){
						outImage[idx + 1] = 1;
					}
					if (g){
						outImage[idx - h] = 1;
					}
				}
            }
            else {
                outImage[idx] = 1;
            }
        }
    }
}