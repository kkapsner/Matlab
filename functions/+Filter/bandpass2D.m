function filtered = bandpass2D(data, sigmaRange, dim)
%bandpass2D performs a bandpass filter with two  symmetric gaussian filters
%in 2D
%   The data is filtered by a weighted moving average. The weighting
%   function is the difference between two gaussian with width
%   sigmaRange(1) and sigmaRange(2).
%   
%   FILTERED = bandpass2D(DATA)             filters the DATA with SIGMARANGE =
%   [1 20]
%   FILTERED = bandpass2D(DATA, SIGMARANGE) filters the DATA with SIGMARANGE
%   FILTERED = bandpass2D(..., DIM)         filters along dimension DIM
    if (nargin < 2)
        sigmaRange = [1 20];
    end
    
    if (nargin < 3)
        [data, nshifts] = shiftdim(data);
        
        filtered = shiftdim( ...
            performGauss(data, sigmaRange), ...
            -nshifts ...
        );
    else
        ndim = ndims(data);
        assert(isscalar(dim) && dim > 0 && dim <= ndim, ...
            'Filter:gauss2D:InvalidDimensions');
        perm = [dim, 1:(dim-1), (dim+1):ndim];
        filtered = ipermute( ...
            performGauss( ...
                permute(data, perm), ...
                sigmaRange ...
            ), ...
            perm ...
        );
    end 

    function filtered = performGauss(data, sigmaRange)
        if (all(sigmaRange == 0))
            filtered = data;
        else
            threeSigma = ceil(3*sigmaRange(2));
            g = 1 - exp(-(-threeSigma:threeSigma).^2/sigmaRange(2)^2);
            if (sigmaRange(1) ~= 0)
                g = g + exp(-(-threeSigma:threeSigma).^2/sigmaRange(1)^2);
            end
            filtered = conv2(g, g, data, 'same') ./ conv2(g, g, ones(size(data)), 'same');
        end
        
    end
end