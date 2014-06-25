function filtered = gauss2D(data, sigma, dim)
%GAUSS2D performs a filter with a symmetric gaussian filter in 2D
%   The data is filtered by a weighted moving average. The weighting
%   function is a  two dimensonal gaussian with width sigma.
%   
%   FILTERED = gauss2D(DATA)              filters the DATA with SIGMA = 3
%   FILTERED = gauss2D(DATA, SIGMA)       filters the DATA with SIGMA
%   FILTERED = gauss2D(DATA, SIGMA, DIM)  filters along dimension DIM
%
%   SEE ALSO: Filter.gauss

    if (nargin < 2)
        sigma = [3 3];
    elseif numel(sigma) < 1
    elseif numel(sigma) < 2
        sigma = [sigma sigma];
    elseif numel(sigma) > 2
        sigma = sigma(1:2);
    end
    
    if (nargin < 3)
        [data, nshifts] = shiftdim(data);
        
        filtered = shiftdim( ...
            performGauss(data, sigma), ...
            -nshifts ...
        );
    else
        ndim = ndims(data);
        assert(isscalar(dim) && dim > 0 && dim <= ndim, ...
            'Filter:gauss2D:InvalidDimensions');
        if (dim == 1)
            filtered = performGauss(data, sigma);
        else 
            perm = [dim, 1:(dim-1), (dim+1):ndim];
            filtered = ipermute( ...
                performGauss( ...
                    permute(data, perm), ...
                    sigma ...
                ), ...
                perm ...
            );
        end
    end 

    function filtered = performGauss(data, sigma)
        if (all(sigma == 0))
            filtered = data;
        else
            threeSigma = ceil(3*sigma);
            g1 = exp(-(-threeSigma(1):threeSigma(1)).^2/sigma(1)^2);
            g2 = exp(-(-threeSigma(2):threeSigma(2)).^2/sigma(2)^2);
            filtered = conv2(g1, g2, data, 'same') ./ conv2(g1, g2, ones(size(data)), 'same');
        end
        
    end
end

