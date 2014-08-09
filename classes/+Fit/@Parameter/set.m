function set(obj, varargin)
%SET multiple set functionality

    for this = obj
        for i = 1:2:nargin-2
        	this.(varargin{i}) = varargin{i+1};
        end
    end
end

