#include "mex.h"
#include <algorithm>
#include <math.h>
#include <iostream>
#include <queue>
#define addToQueue(x, y) if ( \
	!floodedImage[(x) * height + (y)] && \
	!image[(x) * height + (y)] \
){ \
	floodedImage[(x) * height + (y)] = 1;\
	xQueue.push(x);\
	yQueue.push(y);\
}

/*
 * fill.cpp
 */

void floodFill(
	const mxLogical *image,
	mxLogical *floodedImage,
	const unsigned int width,
	const unsigned int height,
	unsigned int x,
	unsigned int y,
	unsigned int &minX,
	unsigned int &maxX,
	unsigned int &minY,
	unsigned int &maxY,
	unsigned int &count
)
{
	std::queue<unsigned int> xQueue;
	std::queue<unsigned int> yQueue;
	
	addToQueue(x, y);
	
	while (xQueue.size()){
		x = xQueue.front();
		xQueue.pop();
		y = yQueue.front();
		yQueue.pop();
		count += 1;
			
		if (x < minX){
			minX = x;
		}
		if (x > maxX){
			maxX = x;
		}
		if (y < minY){
			minY = y;
		}
		if (y > maxY){
			maxY = y;
		}
		
		if (x > 0){
			addToQueue(x - 1, y);
			if (y > 0){
				addToQueue(x - 1, y - 1);
			}
			if (y < height - 1){
				addToQueue(x - 1, y + 1);
			}
		}
		if (y > 0){
			addToQueue(x, y - 1);
		}
		if (y < height - 1){
			addToQueue(x, y + 1);
		}
		if (x < width - 1){
			addToQueue(x + 1, y);
			if (y > 0){
				addToQueue(x + 1, y - 1);
			}
			if (y < height - 1){
				addToQueue(x + 1, y + 1);
			}
		}
	}
}

void copyFilling(
	const mxLogical *src,
	mxLogical *dest,
	const unsigned int width,
	const unsigned int height,
	const unsigned int minX,
	const unsigned int maxX,
	const unsigned int minY,
	const unsigned int maxY
)
{
	for (unsigned int x = minX; x <= maxX; x += 1){
		for (unsigned int y = minY; y <= maxY; y += 1){
			unsigned int idx = x * height + y;
			dest[idx] = src[idx] | dest[idx];
		}
	}
}
void clearFilling(
	mxLogical *image,
	const unsigned int width,
	const unsigned int height,
	const unsigned int minX,
	const unsigned int maxX,
	const unsigned int minY,
	const unsigned int maxY
)
{
	for (unsigned int x = minX; x <= maxX; x += 1){
		for (unsigned int y = minY; y <= maxY; y += 1){
			unsigned int idx = x * height + y;
			image[idx] = 0;
		}
	}
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	unsigned int maxHoleSize;
    mxLogical *image, *fillImage, *outImage;
    mwSize w, h;
	
	if (nrhs == 0){
		mexErrMsgIdAndTxt( "MATLAB:fill:wrongInputCount",
				"At least one input (image) expected.");
	}
	if (nrhs == 1 || mxGetM(prhs[1]) * mxGetN(prhs[1]) == 0){
		maxHoleSize = 5;
	}
	else {
		maxHoleSize = (unsigned int) mxGetScalar(prhs[1]);
	}
	
	if (nrhs > 2){
		mexErrMsgIdAndTxt( "MATLAB:fill:wrongInputCount",
				"Too many input parameter.");
	}
	
	/* The input must be a logical.*/
	if(!mxIsLogical(prhs[0])){
		mexErrMsgIdAndTxt( "MATLAB:fill:inputNotLogical",
				"Input must be a logical.");
	}

    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
    image = mxGetLogicals(mxDuplicateArray(prhs[0]));

    /* Create matrix for the return argument. */
    plhs[0] = mxDuplicateArray(prhs[0]);
    outImage = mxGetLogicals(plhs[0]);
	
	fillImage = mxGetLogicals(mxCreateLogicalMatrix(h, w));
	
	for (unsigned int x = 0; x < w; x += 1){
        unsigned int x_ = x * h;
		for (unsigned int y = 0; y < h; y += 1){
            unsigned int idx = x_ + y;
			
			if (!image[idx]){
				unsigned int
					minX = w,
					maxX = 0,
					minY = h,
					maxY = 0,
					count = 0;
				
				floodFill(
					image, fillImage,
					w, h, x, y,
					minX, maxX, minY, maxY,
					count
				);
				
				if (count <= maxHoleSize){
					copyFilling(
						fillImage, outImage,
						w, h,
						minX, maxX, minY, maxY
					);
				}
				copyFilling(
					fillImage, image,
					w, h,
					minX, maxX, minY, maxY
				);
				clearFilling(
					fillImage,
					w, h,
					minX, maxX, minY, maxY
				);
			}
		}
	}
}