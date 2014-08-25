function smoothedVideo = smooth(video, varargin)
    p = inputParser();
    p.addParameter('filterType', 'gauss', @ischar);
    p.addParameter('strength', 2, @(s)isnumeric(s) && isscalar(s));
    p.parse(varargin{:})
    
    smoothedVideo = zeros(size(video));
    
    if (ndims(video) == 3)
        for i = 1:size(video, 3)
            smoothedVideo(:, :, i) = filter(video(:, :, i));
        end
    elseif (ndims(video) == 4)
        for i = 1:size(video, 4)
            smoothedVideo(:, :, 1, i) = filter(video(:, :, 1, i));
            smoothedVideo(:, :, 2, i) = filter(video(:, :, 2, i));
            smoothedVideo(:, :, 3, i) = filter(video(:, :, 3, i));
        end
    end
    
    function filtered = filter(image)
        switch (p.Results.filterType)
            case 'gauss'
                filtered = Filter.gauss2D(image, p.Results.strength);
            case 'median'
                filtered = medfilt2(image, [1, 1] * p.Results.strength);
            otherwise
                error('Image:smooth:unknownFilterType', 'Unknonw filter type.')
        end
    end
end