function alphaplot(X, Y, alpha, color, varargin)
    if (nargin < 2)
        Y = X;
        X = [];
        alpha = 0.2;
    elseif (nargin < 3)
        if (numel(Y) == 1)
            alpha = Y;
            Y = X;
            X = [];
        else
            alpha = 0.2;
        end
    end
    
    if (nargin < 4)
        color = 'k';
    end
    
    if (isempty(X))
        X = (1:size(Y, 1))' * ones(1, size(Y, 2));
    end
    
    if (isvector(X))
        X = reshape(X, numel(X), 1) * ones(1, size(Y, 2));
    end
    
    Y = [Y; Y(end:-1:1, :)];
    X = [X; X(end:-1:1, :)];
    
    
    patch(X(:), Y(:), color, 'EdgeColor', color, 'EdgeAlpha', alpha, varargin{:});
    
%     dataSize = size(Y, 2);
%     
%     for i = 0:250:(dataSize - 251)
%         patch(X(:, i + (1:250)), Y(:, i + (1:250)), color, 'EdgeColor', color, 'EdgeAlpha', alpha, varargin{:});
%     end
%     
%     patch(X(:, (i + 250):dataSize), Y(:, (i + 250):dataSize), color, 'EdgeColor', color, 'EdgeAlpha', alpha, varargin{:});

end

