function video = getVideo(this, numFrames, verbose)

    if (nargin < 2 || isempty(numFrames))
        numFrames = this.size;
    else
        numFrames = min(numFrames, this.size);
    end
    
    if (nargin < 3)
        verbose = false;
    end
    
    
    if (verbose)
        disp('Loaded video from cache.');
    end
    
    video = this.video(:, :, 1:numFrames);
end

