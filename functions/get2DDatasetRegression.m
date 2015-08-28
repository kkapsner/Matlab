function [cx, cy, alpha, var1, var2] = get2DDatasetRegression(x, y, w)
%GET2DDATASETREGRESSION calculates the regression line of a 2D dataset
%
%   [CX, CY, ALPHA] = get2DDatasetRegression(X, Y) returns the center of
%       weight (CX, CY) and the angle of the best fitting regression line
%   [...] = get2DDatasetRegression(..., W) every data point can be weighted
%       by the W parameter.
%   [..., VAR1, VAR2] = get2DDatasetRegression(...) also returns the
%       variance orthogonal to the line (VAR1) and parallel to the line
%       (VAR2)

    x = reshape(x, [], 1);
    y = reshape(y, [], 1);
    
    if (nargin < 3)
        w = ones(size(x));
    else
        w = reshape(w, [], 1);
    end
    
    wSum = sum(w);
    cx = sum(x .* w) / wSum;
    cy = sum(y .* w) / wSum;
    
    x = (x - cx) .* w;
    y = (y - cy) .* w;
    
    A = sum(x.^2);
    B = sum(y.^2);
    C = sum(x.*y);
    
    alpha = atan(2*C / (A - B)) / 2;
    
    var1 = sin(alpha).^ 2 * A + cos(alpha) .^ 2 * B - 2 * sin(alpha) * cos(alpha) * C;
    var2 = cos(alpha).^ 2 * A + sin(alpha) .^ 2 * B + 2 * sin(alpha) * cos(alpha) * C;
    
    if (var1 > var2)
        alpha = alpha + pi/2;
        [var1, var2] = deal(var2, var1);
    end
    
    var1 = var1 / wSum;
    var2 = var2 / wSum;
end