function image = drawHalfLine(image, x, y, dx, dy)
%IMAGE.DRAWHALFLINE draws a half line
%
%   IMAGE = Image.drawHalfLine(IMAGE, X, Y, DX, DY) draws a half line in
%       IMAGE starting at (X, Y) in the direction specified by DX and DY.
%
% SEE ALSO: Image.getHalfLineCoordinates
    imSize = size(image);
    [x, y] = Image.getHalfLineCoordinates(x, y, dx, dy, imSize);
    image(sub2ind2D(imSize, y, x)) = true;
end