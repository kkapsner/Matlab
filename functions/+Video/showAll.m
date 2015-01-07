function showAll(video, varargin)
    p = inputParser();
    p.parse(varargin{:})
    
    if (ndims(video) == 3)
        numFrames = size(video, 3);
        for i = 1:numFrames
            ax = subplot(1, numFrames, i);
            im = image(video(:, :, i), 'parent', ax);
            ax.DataAspectRatio = [1, 1, 1];
            ax.CLim = [0, 1];
            im.CDataMapping = 'scaled';
            colormap(gray());
        end
    elseif (ndims(video) == 4)
        numFrames = size(video, 4);
        for i = 1:numFrames
            ax = subplot(1, numFrames, i);
            image(video(:, :, :, i), 'parent', ax);
            ax.DataAspectRatio = [1, 1, 1];
        end
    end
end