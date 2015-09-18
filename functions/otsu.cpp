#include "mex.h"
#define runWithType(type) \
{ \
	type *data; \
	data = (type *) mxGetData(prhs[0]); \
	type min, max; \
	min = data[0]; \
	max = data[0]; \
	for (mwSize k = 1; k < N; k += 1){ \
		if (!mxIsNaN(data[k]) && mxIsFinite(data[k])){ \
			if (min > data[k]){ \
				min = data[k]; \
			} \
			else if (max < data[k]){ \
				max = data[k]; \
			} \
		} \
	} \
	type diff = max - min; \
	n = new uint64_T[L]; \
	for (mwSize k = 0; k < L; k += 1){ \
		n[k] = 0; \
	} \
	for (mwSize i = 0; i < N; i += 1){ \
		if (!mxIsNaN(data[i])){ \
			mwSize index = 0; \
			if (mxIsFinite(data[i])){ \
				if (data[i] == max){ \
					index = L - 1; \
				} \
				else { \
					long double current = (long double) (data[i] - min); \
					current *= L; \
					current /= diff; \
					index = current; \
				} \
			} \
			else { \
				if (data[i] < 0){ \
					index = 0; \
				} \
				else { \
					index = L - 1; \
				} \
			} \
			n[index] += 1; \
		} \
		else { \
			N -= 1; \
		} \
	} \
	dataMin = min; \
	dataDiff = diff; \
}
/*
 * otsu.cpp
 */

void error(const char *errorid, const char *errormsg){
	char *completeErrorId;
	sprintf(completeErrorId, "MATLAB:otsu:%s", errorid);
	mexErrMsgIdAndTxt(completeErrorId, errormsg);
}
void assert(int expression, const char *errorid, const char *errormsg){
	if (!expression){
		error(errorid, errormsg);
	}
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	/* Variable names according to:
		N. Otsu: „A Threshold Selection Method from Gray-Level Histograms“
		IEEE Transactions on Systems, Man, and Cybernetics 9.1 (Jan. 1979), S. 62–66.
		issn: 0018-9472.
		doi: 10.1109/tsmc.1979.4310076.
	*/
	mwSize N, L;
	uint64_T *n;
	uint64_T cumSum;
	double *omega, *mu, *sigma2_B;
	double mu_T, maxSigma2_B, dataMin, dataDiff;
	mwSize maxKSum, maxKCount;
	/* Validate function call */
	assert(nrhs == 1, "wrongInputCount", "One input expected.");
	assert(nlhs > 0 && nlhs < 3, "wrongOutputCount", "One or two outputs expected.");
	assert(mxIsNumeric(prhs[0]), "noNumericInput", "Input has to be numeric.");
	assert(!mxIsComplex(prhs[0]), "complexInput", "Input must not be complex");
	
	N = mxGetM(prhs[0]) * mxGetN(prhs[0]);
	if (N == 0){
		
	}
	assert(N != 0, "emptyInput", "Input must not be empty");
	
	L = 256;
	switch (mxGetClassID(prhs[0])){
		case mxDOUBLE_CLASS:
			runWithType(double);
			break;
		case mxSINGLE_CLASS:
			runWithType(float);
			break;
		case mxINT8_CLASS:
			runWithType(int8_T);
			break;
		case mxUINT8_CLASS:
			runWithType(uint8_T);
			break;
		case mxINT16_CLASS:
			runWithType(int16_T);
			break;
		case mxUINT16_CLASS:
			runWithType(uint16_T);
			break;
		case mxINT32_CLASS:
			runWithType(int32_T);
			break;
		case mxUINT32_CLASS:
			runWithType(uint32_T);
			break;
		case mxINT64_CLASS:
			runWithType(int64_T);
			break;
		case mxUINT64_CLASS:
			runWithType(uint64_T);
			break;
		default:
			error("unknownNumericalType", "Unknown numerical type.");
	}
	
	cumSum = n[0];
	omega = new double[L];
	omega[0] = (double) cumSum / N;
	mu = new double[L];
	mu[0] = omega[0];
	for (mwSize k = 1; k < L; k += 1){
		cumSum += n[k];
		omega[k] = (double) cumSum / N;
		mu[k] = mu[k - 1] + (double) n[k] * ((double) k + 1) / N;
	}
	mu_T = mu[L - 1];
	
	sigma2_B = new double[L];
	for (mwSize k = 0; k < L; k += 1){
		double numerator = (mu_T * omega[k] - mu[k]);
		sigma2_B[k] = numerator * numerator / (omega[k] * (1 - omega[k]));
	}
	
	maxSigma2_B = sigma2_B[0];
	maxKSum = 0;
	maxKCount = 1;
	for (mwSize k = 1; k < L; k += 1){
		if (sigma2_B[k] == maxSigma2_B){
			maxKSum += k;
			maxKCount += 1;
		}
		else if (sigma2_B[k] > maxSigma2_B){
			maxSigma2_B = sigma2_B[k];
			maxKSum = k;
			maxKCount = 1;
		}
	}

    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleScalar(((double) dataDiff *  maxKSum) / L / maxKCount + dataMin);
	if (nlhs == 2){
		double sigma2 = 0;
		for (mwSize k = 0; k < L; k += 1){
			sigma2 += (double) n[k] / N * ((double) k + 1) * ((double) k + 1);
		}
		plhs[1] = mxCreateDoubleScalar(maxSigma2_B / (sigma2 - mu_T * mu_T));
	}
	
	/* free memory */
	delete[] n;
	n = nullptr;
	delete[] omega;
	omega = nullptr;
	delete[] mu;
	mu = nullptr;
	delete[] sigma2_B;
	sigma2_B = nullptr;
}