function projection = getXYProjection(this, projectionFunction, numFrames, verbose)
    if (nargin < 2)
        projectionFunction = @mean;
    end
    
    if (nargin < 3 || isempty(numFrames))
        numFrames = this.size;
    else
        numFrames = min(numFrames, this.size);
    end
    
    if (nargin < 4)
        verbose = false;
    end
    
    video = this.getVideo(numFrames, verbose);
    
    functionArguments = getFunctionArguments(projectionFunction);
    if (numel(functionArguments) > 1 && any(strcmpi('dim', functionArguments)))
        args = cell(1, numel(functionArguments));
        args{1} = video;
        args{strcmpi('dim', functionArguments)} = 3;
        projection = projectionFunction(args{:});
    else
        projection = zeros(this.height, this.width);
        numPixels = numel(projection);
        if (verbose)
            fprintf('\nProjecting:\n    % 5i / % 5i (% 3i%%)', 0, numPixels, 0);
        end
        for x = 1:this.width
            for y = 1:this.height
                if (verbose)
                    i = (x - 1) * this.height + y;
                    fprintf(char(repmat(8, 1, 20)));
                    fprintf('% 5i / % 5i (% 3i%%)', i, numPixels, round(100 * i / numPixels));
                end
                projection(x, y) = projectionFunction(reshape(video(x, y, :), [], 1));
            end
        end
    end
    
    if (verbose)
        fprintf('\nfinished.\n');
    end
end