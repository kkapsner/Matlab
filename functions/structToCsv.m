function structToCsv(struct, file, varargin)
    if (nargin < 2)
        file = [];
    end
    
    objectToCsv(struct, fieldnames(struct)', file, varargin{:});
end