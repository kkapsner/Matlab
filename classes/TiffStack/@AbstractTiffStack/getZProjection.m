function varargout = getZProjection(stack, projectionFunction, numFrames, verbose)
    if (nargin < 2)
        projectionFunction = @mean;
    end
    
    if (nargin < 3 || isempty(numFrames))
        numFrames = stack.size;
    else
        numFrames = min(numFrames, stack.size);
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
        image = stack.getImage(i);
        [funcout{:}] = projectionFunction(image(:));
        
        for outIdx = 1:nargout
            varargout{outIdx}(i) = funcout{outIdx};
        end
    end
    
    if (verbose)
        disp(' finished.');
    end
end