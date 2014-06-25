function m = cumMean(A, dim)
%CUMMEAN calculates the cummultative mean in a matrix
%
%   B = CUMMEAN(A, DIM) calculates the cummultative mean of the matrix A
%   along the dimension DIM.
%   Cummultative means that B(i, j) = mean(A(1:i, j)) (assuming DIM == 1)
%   
%   B = CUMMEAN(A) calculates along the first nonsingular dimension.
%
%   SEE ALSO: mean

    if (nargin < 2)
        [A, nshifts] = shiftdim(A);
    elseif (dim ~= 1)
        ndim = ndims(A);
        assert(isscalar(dim) && dim > 0 && dim <= ndim, ...
            'cumMean:InvalidDimensions');
        perm = [dim, 1:(dim-1), (dim+1):ndim];
        A = permute(A, perm);
    end
    
    m = zeros(size(A));
    dataSize = size(A, 1);
    for i = 1:dataSize
        m(i, :) = meanWithNaN(A(1:i, :), 1);
    end
    
    
    if (nargin < 2)
        m = shiftdim( ...
            m, ...
            -nshifts ...
        );
    elseif (dim ~= 1)
        m = ipermute( ...
            m, ...
            perm ...
        );
    end
end