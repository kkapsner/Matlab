function video = normalise(video, varargin)
    p = inputParser();
    p.addParameter('global', false, @islogical);
    p.addParameter('ignoreBottom', 0, @isnumeric);
    p.addParameter('ignoreTop', 0, @isnumeric);
    
    p.parse(varargin{:});
    
    if (p.Results.global)
       [mi, ma] = mima(video(:));
       video = (video - mi) / (ma - mi);
    else
        if (ndims(video) == 3)
            for i = 1:size(video, 3)
                image = video(:, :, i);
                [mi, ma] = mima(image(:));
                video(:, :, i) = (image - mi) / (ma - mi);
            end
        elseif (ndism(video) == 4)
            for i = 1:size(video, 4)
                image = video(:, :, :, i);
                [mi, ma] = mima(image(:));
                video(:, :, :, i) = (image - mi) / (ma - mi);
            end
        end
    end
    
    function [mi, ma] = mima(A)
        mi = quantile(A, p.Results.ignoreBottom);
        ma = quantile(A, 1 - p.Results.ignoreTop);
    end
end