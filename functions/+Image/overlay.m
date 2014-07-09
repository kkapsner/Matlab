function image = overlay(image, overlayImage, color)
    if (ismatrix(image))
        image = image | overlayImage;
    else
        if (nargin < 3)
            color = [1, 1, 1];
        end
        filter = find(overlayImage);
        image(filter + 0*size(image, 1)*size(image, 2)) = color(1);
        image(filter + 1*size(image, 1)*size(image, 2)) = color(2);
        image(filter + 2*size(image, 1)*size(image, 2)) = color(3);
        
    end
end