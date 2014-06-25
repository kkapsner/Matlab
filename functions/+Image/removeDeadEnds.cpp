#include "mex.h"
#include <algorithm>
#include <math.h>
#include <iostream>
#define image(x, y) image[(x) * height + (y)]

/*
 * fill.cpp
 */

void checkDeadEnd(
	mxLogical *image,
	const unsigned int width,
	const unsigned int height,
	const unsigned int x,
	const unsigned int y
)
{
	if (!image(x, y)){
		unsigned int neighbors = 0;
		bool border = false;
		if (x > 0){
			neighbors += !image(x - 1, y + 0);
			if (y > 0){
				neighbors += !image(x - 1, y - 1);
			}
			else {
				border = true;
			}
			if (y < height - 1){
				neighbors += !image(x - 1, y + 1);
			}
			else {
				border = true;
			}
		}
		else {
			border = true;
		}
		
		if (y > 0){
			neighbors += !image(x - 0, y - 1);
		}
		else {
			border = true;
		}
		if (y < height - 1){
			neighbors += !image(x - 0, y + 1);
		}
		else {
			border = true;
		}
		
		if (x < width - 1){
			neighbors += !image(x + 1, y + 0);
			if (y > 0){
				neighbors += !image(x + 1, y - 1);
			}
			else {
				border = true;
			}
			if (y < height - 1){
				neighbors += !image(x + 1, y + 1);
			}
			else {
				border = true;
			}
		}
		else {
			border = true;
		}
		
		
		// std::cout << x << "|" << y << " > " << neighbors << std::endl;
		
		if ((!border && neighbors < 2) || (border && neighbors < 2)){
			image(x, y) = 1;
			if (x > 0){
				checkDeadEnd(image, width, height, x - 1, y + 0);
				if (y > 0){
					checkDeadEnd(image, width, height, x - 1, y - 1);
				}
				if (y < height - 1){
					checkDeadEnd(image, width, height, x - 1, y + 1);
				}
			}
			
			if (y > 0){
				checkDeadEnd(image, width, height, x + 0, y - 1);
			}
			if (y < height - 1){
				checkDeadEnd(image, width, height, x + 0, y + 1);
			}
			
			if (x < width - 1){
				checkDeadEnd(image, width, height, x + 1, y + 0);
				if (y > 0){
					checkDeadEnd(image, width, height, x + 1, y - 1);
				}
				if (y < height - 1){
					checkDeadEnd(image, width, height, x + 1, y + 1);
				}
			}
		}
	}
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    mxLogical *image;
    mwSize w, h;
	
	if (nrhs != 1){
		mexErrMsgIdAndTxt( "MATLAB:fill:wrongInputCount",
				"One input (image) expected.");
	}
	
	/* The input must be a logical.*/
	if(!mxIsLogical(prhs[0])){
		mexErrMsgIdAndTxt( "MATLAB:fill:inputNotLogical",
				"Input must be a logical.");
	}

    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);

    /* Create matrix for the return argument. */
    plhs[0] = mxDuplicateArray(prhs[0]);
    image = mxGetLogicals(plhs[0]);
	
	for (unsigned int x = 0; x < w; x += 1){
		for (unsigned int y = 0; y < h; y += 1){
            checkDeadEnd(image, w, h, x, y);
		}
	}
	
}