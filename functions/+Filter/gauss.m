function filtered = gauss(data, sigma, dim)
%GAUSS performs a filter with a symmetric gaussian filter
%   The data is filtered by a weighted moving average. The weighting
%   function is a gaussian with width sigma.
%   
%   FILTERED = gauss(DATA)              filters the DATA with SIGMA = 3
%   FILTERED = gauss(DATA, SIGMA)       filters the DATA with SIGMA
%   FILTERED = gauss(DATA, SIGMA, DIM)  filters along dimension DIM
    if (nargin < 2)
        sigma = 3;
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
            'Filter:gauss:InvalidDimensions');
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
        if (sigma == 0)
            filtered = data;
        else
            threeSigma = ceil(3*sigma);
            g = exp(-(-threeSigma:threeSigma).^2/2/sigma^2);
            
            filtered = zeros(size(data));
            for i = 1:size(data, 2)
                filtered(:, i) = conv(data(:, i), g, 'same') ./ ...
                    conv(ones(size(data(:, i))), g, 'same');
            end
        end
        
    end

