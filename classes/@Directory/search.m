function found = search(obj, search)
%SEARCH 
%   
    if (nargin < 2)
        search = '';
    end
    
    found = dir([obj.path, filesep, search]);

end

