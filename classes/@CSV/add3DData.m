function this = add3DData(this, xName, x, yName, y, zName, z, varargin)
    if (nargin == 4)
        z = yName;
        y = x;
        x = xName;
        xName = 'x';
        yName = 'y';
        zName = 'z';
    end
    assert(numel(x) == size(z, 2), 'CSV:add3DData:wrongDimensions', 'Dimensions have to match');
    assert(numel(y) == size(z, 1), 'CSV:add3DData:wrongDimensions', 'Dimensions have to match');
    
    p = inputParser();
    p.addParameter('scanXFirst', true, @islogical);
    p.parse(varargin{:});
    
    x = ones(size(z, 1), 1) * reshape(x, 1, []);
    y = reshape(y, [], 1) * ones(1, size(z, 2));
    
    if (p.Results.scanXFirst)
        x = x';
        y = y';
        z = z';
    end
    
    this ...
        .addColumn(xName, x) ...
        .addColumn(yName, y) ...
        .addColumn(zName, z) ...
    ;
end