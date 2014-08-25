function overlayedImage = overlay(video, overlayVideo, varargin)
    
    if (ndims(video) == 3)
        overlayedImage = Video.gray2rgb(video);
    else
        overlayedImage = video;
    end
    
    for i = 1:size(overlayedImage, 4)
        overlayedImage(:, :, :, i) = Image.overlay(overlayedImage(:, :, :, 1), overlayVideo(:, :, i), varargin{:});
    end
end