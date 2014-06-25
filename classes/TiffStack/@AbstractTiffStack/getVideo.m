function video = getVideo(this, numFrames, verbose)
%getVideo extracts the complete video out of a tiff stack
%   DO NOT OVERWRITE THIS FUNCTION IN SUBCLASSES OF TiffStack!

    if (nargin < 2 || isempty(numFrames))
        numFrames = this.size;
    else
        numFrames = min(numFrames, this.size);
    end
    
    if (nargin < 3)
        verbose = false;
    end
    
    
    if (verbose)
        fprintf('Getting video:\n    % 5i / % 5i (% 3i%%)', 0, numFrames, 0);
    end
    
    video = zeros(this.info(1).Height, this.info(1).Width, numFrames);
    for i = 1:numFrames
        if (verbose)
            fprintf(char(repmat(8, 1, 20)));
            fprintf('% 5i / % 5i (% 3i%%)', i, numFrames, round(100 * i / numFrames));
        end
        video(:, :, i) = this.getImage(i);
    end
    
    if (verbose)
        fprintf('\nfinished.\n');
    end
end

