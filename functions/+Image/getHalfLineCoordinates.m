function [xC, yC] = getHalfLineCoordinates(x, y, dx, dy, w, h)
%IMAGE.GETHALFLINECOORDINATES returns the coordinates of a half line
%
%   [xC, yC] = Image.getHaldLineCoordinates(X, Y, DX, DY, SIZE) returns the
%       coordinates of the pixels for a half line starting at (X, Y) in the
%       direction specified by DX and DY. SIZE is the size of the image.
%   [xC, yC] = Image.getHaldLineCoordinates(X, Y, DX, DY, W, H) instead of
%       the size the width W and height H can be specified separately.
%
% Example:
%   image = zeros(100, 100);
%   [xC, yC] = Image.getHalfLineCoordinates(50, 50, 1, 3, size(image));
%   image(sub2ind(size(image), yC, xC)) = 1;
    if (nargin < 6 && numel(w) == 2)
        h = w(1);
        w = w(2);
    end
    
    if (abs(dx) < abs(dy))
        [yC, xC] = Image.getHalfLineCoordinates(y, x, dy, dx, h, w);
    else
        if (dx == 0)
            error('Image:getHalfLineCoordinates:invalidSlope', 'Invalid slope defined.');
        elseif (dx < 0)
            xBorder = 1;
        else
            xBorder = w;
        end
        yBorder = y + (xBorder - x) * dy / dx;
        
        if (yBorder < 1)
            xBorder = x + (1 - y) * dx / dy;
            yBorder = 1;
        elseif (yBorder > h)
            xBorder = x + (h - y) * dx / dy;
            yBorder = h;
        end
        xC = x:sign(dx):xBorder;
        yC = round(interp1([x, xBorder], [y, yBorder], xC, 'linear'));
    end
end