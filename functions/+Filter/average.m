function filtered = average(data, sigma, dim)
%AVERAGE performs a filter with a symmetric average filter
%   The data is filtered by a moving average.
%   
%   FILTERED = average(DATA)              filters the DATA with SIGMA = 3
%   FILTERED = average(DATA, SIGMA)       filters the DATA with SIGMA
%   FILTERED = average(DATA, SIGMA, DIM)  filters along dimension DIM
    if (nargin < 2)
        sigma = 3;
    end
    
    if (nargin < 3)
        [data, nshifts] = shiftdim(data);
        
        filtered = shiftdim( ...
            performAverage(data, sigma), ...
            -nshifts ...
        );
    else
        ndim = ndims(data);
        assert(isscalar(dim) && dim > 0 && dim <= ndim, ...
            'Filter:average:InvalidDimensions');
        perm = [dim, 1:(dim-1), (dim+1):ndim];
        filtered = ipermute( ...
            performAverage( ...
                permute(data, perm), ...
                sigma ...
            ), ...
            perm ...
        );
    end 

    function filtered = performAverage(data, sigma)
        if (sigma == 0)
            filtered = data;
        else
            g = ones(1, 2*sigma + 1);
            filtered = conv(data, g, 'same') ./ conv(ones(size(data)), g, 'same');
        end
        
    end
end

