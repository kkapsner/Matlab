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

    x = x(:);
    y = y(:);
    
    if (nargin < 3)
        w = ones(size(x));
    else
        w = w(:);
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
    
    s = sin(alpha);
    c = cos(alpha);
    
    var1 = s * s * A + c * (c * B - 2 * s * C);
    var2 = A + B - var1;
%     var2 = c * c * A + s * (s * B + 2 * c * C);
    
    if (var1 > var2)
        alpha = alpha + pi/2;
        help = var1;
        var1 = var2;
        var2 = help;
    end
    
    var1 = var1 / wSum;
    var2 = var2 / wSum;
end