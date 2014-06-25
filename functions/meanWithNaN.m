function [meanA, error] = meanWithNaN(A, dim)
    if (nargin < 2)
        [A, nshifts] = shiftdim(A);
    elseif (dim ~= 1)
        
        ndim = ndims(A);
        assert(isscalar(dim) && dim > 0 && dim <= ndim, ...
            'meanWithNaN:InvalidDimensions');
        perm = [dim, 1:(dim-1), (dim+1):ndim];
        A = permute(A, perm);
    end
    
    s = size(A);
    s(1) = 1;
    meanA = zeros(s);
    error = zeros(s);
    
    for i = 1:prod(s)
        v = A(:, i);
        notNaN = ~isnan(v);
        meanA(i) = sum(v(notNaN)) / sum(notNaN);
        error(i) = std(v(notNaN)) / sqrt(sum(notNaN));
    end
    
    
    if (nargin < 2)
        meanA = shiftdim( ...
            meanA, ...
            -nshifts ...
        );
        
        error = shiftdim( ...
            error, ...
            -nshifts ...
        );
    elseif (dim ~= 1)
        meanA = ipermute(meanA, perm);
        error = ipermute(error, perm);
    end
end