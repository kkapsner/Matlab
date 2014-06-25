function shift = getShift(image1, image2)
%getShift
%   shift = getShift(image1, image2)
    
    imageSize = size(image1);
    
%     fimage1 = fft2(image1);
%     % rotate image2 by 180°
%     fimage2 = fft2(image2(end:-1:1,end:-1:1));
%     mul = fimage1 .* fimage2;
%     crossCorrelation = ifft2(mul);
    crossCorrelation = ifft2( ...
        fft2(image1) .* fft2(image2(end:-1:1,end:-1:1)) ...
    );
    
    [~, maxIdx] = max(crossCorrelation(:));
    [maxY, maxX] = ind2sub(imageSize, maxIdx);
    
    shift = [ ...
        mod(maxY + imageSize(1)/2, imageSize(1)) - imageSize(1)/2 - 1, ...
        mod(maxX + imageSize(2)/2, imageSize(2)) - imageSize(2)/2 - 1 ...
    ];
end

