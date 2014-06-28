function varargout = getZProjection(this, projectionFunction, numFrames, verbose)
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
    
    varargout = cell(nargout, 1);
    funcout = cell(nargout, 1);
    for i = 1:nargout
        varargout{i} = zeros(numFrames, 1);
    end
    
    if (verbose)
        disp('Start projecting:');
        fprintf('    % 3i%%', 0);
    end
    
    for i = 1:numFrames
        if (verbose)
            fprintf(char(repmat(8, 1, 4)));
            fprintf('% 3i%%', round(100 * i / numFrames));
        end
        image = this.getImage(i);
        [funcout{:}] = projectionFunction(image(:));
        
        for outIdx = 1:nargout
            varargout{outIdx}(i) = funcout{outIdx};
        end
    end
    
    if (verbose)
        disp(' finished.');
    end
end