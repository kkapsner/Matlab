function output = arrayfun1d(fun, data, dim)

    ndim = ndims(data);
    assert(isscalar(dim) && dim > 0 && dim <= ndim, ...
        'arrayfun1d:InvalidDimensions');
    perm = [dim, 1:(dim-1), (dim+1):ndim];
    data = permute(data, perm);
    
    dataSize = size(data, 1);
    output = zeros(dataSize, 1);
    
    for i = 1:dataSize
        output(i) = fun(data(i, :));
    end
end