function filtered = median1d(data, windowSize, dim)
%MEDIAN1D Performs a median filter
%   this function does a similar task than medfilt1 BUT it has a less insane
%   handling of the data borders.
%   Additional it runs faster (depending on data and window size between 10
%   an 100-fold). It also consumes less memory.
%   
%       FILTERED = median1d(DATA, WINDOWSIZE) filters the DATA with the
%       given WINDOWSIZE.
%       FILTERED = median1d(..., dim) spezifies the dimension that should
%       be filtered. Default is the first non singleton dimension.
%   
%   See also MEDFILT1, MEDIAN1D_CPP
    
    if (windowSize <= 1)
        filtered = data;
    elseif (nargin < 3)
        [data, nshifts] = shiftdim(data);
        
        filtered = shiftdim( ...
            Filter.median1d_cpp(data, windowSize), ...
            -nshifts ...
        );
    else
        ndim = ndims(data);
        assert(isscalar(dim) && dim > 0 && dim <= ndim, ...
            'Filter:median1d:InvalidDimensions');
        perm = [dim, 1:(dim-1), (dim+1):ndim];
        filtered = ipermute( ...
            Filter.median1d_cpp( ...
                permute(data, perm), ...
                windowSize ...
            ), ...
            perm ...
        );
    end 
end

