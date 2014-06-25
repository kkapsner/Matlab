function rotatedMean = getRotationMean(img, stepSize)
    if (nargin < 2)
        stepSize = 10;
    end
    imgSize = size(img);
    rotatedMean = double(img);
    for i=stepSize:stepSize:359
        rotatedImage = imrotate(img, i, 'bilinear', 'crop');
        rotatedSize = size(rotatedImage);
        convData = conv2(double(img), double(rotatedImage));
        [maxRow, rows] = max(convData);
        [convMax, col] = max(maxRow);
        row = rows(col);
        
        tform = maketform('affine', [ ...
            1 0 0; ...
            0 1 0; ...
            (col-rotatedSize(1)), (row-rotatedSize(2)), 1] ...0 0 1] ...
        );
        rotatedTranslatedImage = imtransform(rotatedImage, tform, ...
            'XData', [1 imgSize(2)], ...
            'YData', [1 imgSize(1)] ...
        );
        rotatedMean = rotatedMean + double(rotatedTranslatedImage);
    end
    rotatedMean = rotatedMean / 36;
end