function image = createDifferenceOverlay(image1, image2, posColor, negColor)
%CREATEDIFFERENCEOVERLAY creates an RGB image out of two images that indicates the differences
%
%	image = createDifferenceOverlay(image1, image2)
%	createDifferenceOverlay(..., posColor, negColor)
%
%	image is the RGB image where same pixel are indicated black/white
%	the different pixels are colored in posColor (pixel got white)
%	and negColor (pixel got black

    if (nargin < 3)
        posColor = [1, 0.5, 0];
        negColor = [0.8, 0, 0];
    end
    image = zeros(size(image1, 1), size(image1, 2), 3);
    image(:, :, 1) = image1;
    image(:, :, 2) = image1;
    image(:, :, 3) = image1;
    image = Image.overlay(image, image2 & ~image1, posColor);
    image = Image.overlay(image, ~image2 & image1, negColor);
end